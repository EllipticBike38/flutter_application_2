import 'package:flutter/material.dart';

class DateTitle extends StatelessWidget {
  DateTitle({
    super.key,
    required this.months,
    required this.selectedDate,
  });
  DateTime selectedDate;
  final List<String> months;

  @override
  Widget build(BuildContext context) {
    return Row(
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      // 20 gennaio 2023 ma gennaio con un font più piccolo e 20 rosso
      children: [
        Text(
          selectedDate.day.toString(),
          style: const TextStyle(
            fontSize: 60,
            color: Colors.red,
          ),
        ),
        Column(
          children: [
            Text(
              months[selectedDate.month - 1],
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              selectedDate.year.toString(),
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
