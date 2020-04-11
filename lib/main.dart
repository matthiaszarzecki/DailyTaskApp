import 'package:flutter/material.dart';

import 'package:daily_task_app/task_screen.dart';

void main() {
  return runApp(DailyTaskApp());
}

class DailyTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Daily Tasks',
      theme: ThemeData(
        // TODO(MZ): Create custom color-theme. Find a nice one!
        primarySwatch: Colors.green,
      ),
      home: const TaskScreen(appBarTitle: 'Your Daily Tasks'),
    );
  }
}
