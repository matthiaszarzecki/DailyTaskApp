import 'package:flutter/material.dart';

import 'package:daily_task_app/screens/task_screen.dart';

void main() {
  return runApp(DailyTaskApp());
}

/*
  // Lower priority:
  // TODO(MZ): Allow editing of streaks
  // TODO(MZ): Remove texts from icon-menu
  // TODO(MZ): Upload to TestFlight & Invite friends
  // TODO(MZ): Replace Cells with Expansion Panels https://medium.com/aubergine-solutions/how-to-create-expansion-panel-list-in-flutter-2fba574366e8
  // TODO(MZ): Use relative imports https://github.com/erluxman/awesomefluttertips
*/

class DailyTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Daily Tasks',
      theme: _buildThemeData(),
      home: const TaskScreen(appBarTitle: 'Your Daily Tasks'),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildThemeData() {
    const int primaryValue = 0xff2899cd;
    const MaterialColor mainColor = MaterialColor(
      primaryValue,
      <int, Color>{
        50: Color(primaryValue),
        100: Color(primaryValue),
        200: Color(primaryValue),
        300: Color(0xff7bc6e9),
        400: Color(primaryValue),
        500: Color(primaryValue),
        600: Color(primaryValue),
        700: Color(primaryValue),
        800: Color(primaryValue),
        900: Color(primaryValue),
      },
    );

    return ThemeData(
      primarySwatch: mainColor,
      iconTheme: IconThemeData(color: mainColor[300]),
    );
  }
}
