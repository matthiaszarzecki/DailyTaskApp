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
      theme: _buildThemeData(),
      home: const TaskScreen(appBarTitle: 'Your Daily Tasks'),
    );
  }

  ThemeData _buildThemeData() {
    MaterialColor mainColor = Colors.green;
    return ThemeData(
      // TODO(MZ): Create custom color-theme. Find a nice one!
      primarySwatch: mainColor,
      iconTheme: IconThemeData(color: mainColor[300]),
    );
  }
}
