import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentTimeWidget extends StatelessWidget {
  const CurrentTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1)).map((_) => DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currentTime = snapshot.data!;
          final formattedTime = DateFormat.Hms().format(currentTime);
          return Text(
            "current time: $formattedTime",
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            //style: Theme.of(context).textTheme.headlineMedium,
          );
        } else {
          return const Text("Loading current time...");
        }
      },
    );
  }
}
