import 'package:flutter/material.dart';
import 'calendarHandle.dart';

class PermitPopUp extends StatefulWidget {
  const PermitPopUp({
    super.key,
    required this.calendarHandle,
    required this.selectedDate,
    required this.updateDateData,
  });
  final Function updateDateData;

  final CalendarHandle calendarHandle;
  final DateTime selectedDate;

  @override
  State<PermitPopUp> createState() => _PermitPopUpState();
}

class _PermitPopUpState extends State<PermitPopUp> {
  var startHour = 8;
  var endHour = 12;

  void updateStartHour(int? value) {
    if (value != null && (value >= endHour)) updateEndHour(value + 1);
    if (value != null && (value >= 8) && (value <= 16)) {
      setState(() {
        startHour = value;
      });
    }
  }

  void updateEndHour(int? value) {
    if (value != null && (value <= startHour)) updateStartHour(value - 1);
    if (value != null && (value >= 9) && (value <= 17)) {
      setState(() {
        endHour = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Orario di inizio'),
            // number 8-17 with 30 min steps
            FormField(builder: (context) {
              return DropdownButton<int>(
                value: startHour,
                items: [
                  for (var i = 8; i < 18; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('$i:00'),
                    ),
                ],
                onChanged: updateStartHour,
              );
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Orario di fine'),
            // number 8-17 with 30 min steps
            FormField(builder: (context) {
              return DropdownButton<int>(
                value: endHour,
                items: [
                  for (var i = 8; i < 18; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('$i:00'),
                    ),
                ],
                onChanged: updateEndHour,
              );
            }),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            widget.calendarHandle
                .createExtraPermit(widget.selectedDate, startHour, endHour)
                .then((value) => widget.updateDateData());
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
