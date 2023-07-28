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
    return _client.send(request..headers.addAll(_headers));
  }
}

class CalendarHandle {
  CalendarHandle(this.controller);
  final SettingsController controller;

  Future<calendar.CalendarApi?> getCalendarApi() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print('user not logged');
      return null;
    }
    GoogleSignInAccount? googleUser;

    while (googleUser == null) {
      try {
        googleUser = await GoogleSignIn(scopes: [
          calendar.CalendarApi.calendarScope,
        ]).signIn();
      } catch (e) {
        print(e);
      }
    }

    var headers = await googleUser?.authHeaders;

    calendar.CalendarApi calendarApi =
        calendar.CalendarApi(MyClient(headers as Map<String, String>));

    return calendarApi;
  }

  Future<String?> getCalendarId() async {
    calendar.CalendarApi? calendarApi = await getCalendarApi();
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
      startDate.toLocal().toString(): {
        'start': event.start?.dateTime?.toLocal(),
        'end': event.end?.dateTime?.toLocal(),
        'type': event.summary?.split(' - ')[0],
      }
    };
  }

  Future<Map<String?, Map<String, Object?>>> readCalendarMonth(
      int month, int year) async {
    calendar.CalendarApi? calendarApi = await getCalendarApi();
    if (calendarApi == null) {
      return {};
    }
    var calendarId = await getCalendarId();
    if (calendarId == null) {
      return {};
    }
    var eventsMap = <String?, Map<String, Object?>>{};
    var events = (await calendarApi.events.list(calendarId,
        timeMin: DateTime(year, month).toUtc(),
        timeMax: DateTime(year, month + 1).toUtc()));
    for (var e in events.items as Iterable) eventsMap.addAll(translateEvent(e));
    return eventsMap;
  }
}
