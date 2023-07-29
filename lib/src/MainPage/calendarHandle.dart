// import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/calendar/v3.dart';
import 'package:http/src/client.dart' as http;
import 'package:http/src/base_client.dart' as http;
import 'package:http/src/streamed_response.dart' as http;
import 'package:http/src/base_request.dart' as http;

import '../settings/settings_controller.dart';

class MyClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  MyClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    print(request..url);
    return _client.send(request..headers.addAll(_headers));
  }
}

class CalendarHandle {
  CalendarHandle(this.controller) {
    calendarApi = getCalendarApi();
    calendarId = getCalendarId();
  }
  final SettingsController controller;
  late Future<calendar.CalendarApi?> calendarApi;
  late Future<String?> calendarId;
  //todo decoratore per gestire l'errore di autenticazione
  Future<T?> checkAuth<T>(
    Future<T?> Function() funCreator,
  ) async {
    T? value;
    if (FirebaseAuth.instance.currentUser == null) {
      print('user not logged');
      return value;
    }
    try {
      value = await funCreator();
    } catch (e) {
      await GoogleSignIn(scopes: [
        calendar.CalendarApi.calendarScope,
      ]).signInSilently();
      calendarApi = getCalendarApi();
      value = await funCreator();
    }
    return value;
  }

  Future<void> createEvent(DateTime day, String type, bool partTime) async {
    return await checkAuth(() => _createEvent(day, type, partTime));
  }

  Future<calendar.CalendarApi?> getCalendarApi() async {
    return _getCalendarApi();
  }

  Future<String?> getCalendarId() async {
    return await checkAuth(() => _getCalendarId());
  }

  Future<List<Map<String?, Map<String, Object?>>>?> readCalendar(
      DateTime start, DateTime end) async {
    return checkAuth(() => _readCalendar(start, end));
  }

  Future<calendar.CalendarApi?> _getCalendarApi() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print('user not logged');
      return null;
    }
    GoogleSignInAccount? googleUser;

    while (googleUser == null) {
      try {
        googleUser = await GoogleSignIn(scopes: [
          calendar.CalendarApi.calendarScope,
        ]).signInSilently();
      } catch (e) {
        print(e);
      }
    }

    var headers = await googleUser.authHeaders;

    calendar.CalendarApi calendarApi = calendar.CalendarApi(MyClient(headers));

    return calendarApi;
  }

  Future<String?> _getCalendarId() async {
    if (!(await GoogleSignIn().isSignedIn())) {
      this.calendarApi = getCalendarApi();
    }
    calendar.CalendarApi? calendarApi = await this.calendarApi;
    if (calendarApi == null) {
      return null;
    }
    for (var i in (await calendarApi.calendarList.list()).items ?? []) {
      if (i.summary == controller.companyName) return i.id;
    }

    return null;
  }

  Map<String?, Map<String, Object?>> translateEvent(Event event) {
    var start = event.start?.dateTime?.toLocal();
    var startDate = DateTime(start!.year, start.month, start.day);
    return {
      startDate.toString().substring(0, 10): {
        'start': event.start?.dateTime,
        'end': event.end?.dateTime,
        'type': event.summary?.split(' - ')[0],
        'id': event.id,
      }
    };
  }

  Future<List<Map<String?, Map<String, Object?>>>> _readCalendar(
      DateTime start, DateTime end) async {
    if (!(await GoogleSignIn().isSignedIn())) {
      this.calendarApi = getCalendarApi();
    }
    calendar.CalendarApi? calendarApi = await this.calendarApi;
    if (calendarApi == null) {
      return [];
    }
    var calendarId = await this.calendarId;
    if (calendarId == null) {
      return [];
    }
    var eventsMap = <String?, Map<String, Object?>>{};
    var permitsMap = <String?, Map<String, Object?>>{};
    var events = (await calendarApi.events.list(calendarId,
        timeMin: start, timeMax: end, timeZone: controller.tmzLocation));
    for (var e in events.items as Iterable) {
      if (e.summary?.split(' - ')[0] == 'Pe') {
        permitsMap.addAll(translateEvent(e));
      } else {
        eventsMap.addAll(translateEvent(e));
      }
    }
    //printami i summary di tutti gli eventi events e poi i permits

    for (var p in List.of(permitsMap.keys)) {
      if (!eventsMap.containsKey(p)) {
        eventsMap.addAll({p: permitsMap[p]!});
        permitsMap.remove(p);
      }
    }
    return [eventsMap, permitsMap];
  }

  Future<List<Map<String?, Map<String, Object?>>>?> readCalendarMonth(
      int month, int year) async {
    return readCalendar(DateTime(year, month, 1), DateTime(year, month + 1, 1));
  }

  Future<List<Map<String, Object?>>> readCalendarDay(DateTime day) async {
    List<Map<String?, Map<String, Object?>>>? dayData = await readCalendar(
        DateTime(day.year, day.month, day.day),
        DateTime(day.year, day.month, day.day + 1));
    if (dayData == null) {
      return [{}, {}];
    }
    var index =
        DateTime(day.year, day.month, day.day).toString().substring(0, 10);
    return [
      dayData![0][index] == null ? {} : dayData[0][index]!,
      dayData[1][index] == null ? {} : dayData[1][index]!,
    ];
  }

  // if this is not a permit (Ps) event already exist a non permit event in that day, delete it and create a new one,
  // else if this is a permit event already exist a permit event in that day, delete it and create a new one
  Future<void> _createEvent(DateTime day, String type, bool partTime) async {
    if (!(await GoogleSignIn().isSignedIn())) {
      this.calendarApi = getCalendarApi();
    }
    calendar.CalendarApi? calendarApi = await this.calendarApi;
    if (calendarApi == null) return;
    var calendarId = await this.calendarId;
    if (calendarId == null) {
      return;
    }

    var events = await calendarApi.events.list(calendarId,
        timeZone: controller.tmzLocation,
        timeMin: DateTime(day.year, day.month, day.day),
        timeMax: DateTime(day.year, day.month, day.day + 1));
    for (var e in events.items as Iterable) {
      // se ci sono più eventi in un giorno, cancella il Pe solo se Type è Pe
      if ((events.items!.length > 1 &&
              type == 'Pe' &&
              e.summary?.split(' - ')[0] == type) ||
          (events.items!.length == 1)) {
        await calendarApi.events.delete(calendarId, e.id!);
      }
    }
    if (type != 'A' && type != 'Vc') {
      var event = calendar.Event(
        summary: '$type - ${controller.companyName}',
        description: 'AutoCalendar ${controller.companyName}}',
        start: calendar.EventDateTime(
            timeZone: controller.tmzLocation,
            dateTime: DateTime(day.year, day.month, day.day, 8, 30)),
        end: calendar.EventDateTime(
            timeZone: controller.tmzLocation,
            dateTime: DateTime(day.year, day.month, day.day, 8, 30).add(
                Duration(
                    hours: (partTime
                        ? 8 * controller.partTimePercentage ~/ 100
                        : 8),
                    minutes: partTime ? 0 : 45))),
      );

      //num to int: (num).toInt()
      await calendarApi.events.insert(event, calendarId);
    }
  }
}
