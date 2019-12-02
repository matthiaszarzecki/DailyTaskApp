import 'dart:convert';
import 'package:daily_task_app/daily_task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStore {
  /// Saves a single daily task to the preferences with continuing index
  static Future<void> saveDailyTask(DailyTask task) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    int length = _getLength(prefs);
    prefs.setInt('length', length + 1);
    prefs.setString('single_task $length', taskAsJson);
    print('Saved: single_task $length');
  }

  // Gets all tasks from the preferences
  static Future<List<DailyTask>> getAllDailyTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DailyTask> tasks = <DailyTask>[
    ];
    int length = _getLength(prefs);
    print('AA');
    print('length: $length');
    print('BB');
    for (int index = 0; index < length; index++) {
      String taskAsString = prefs.getString('single_task $index');
      print(taskAsString);
      Map<String, dynamic> taskAsMap = jsonDecode(taskAsString);
      DailyTask task = DailyTask.fromJson(taskAsMap);
      tasks.add(task);
    }
    print('CC');
    return tasks;
  }

  static int _getLength(SharedPreferences prefs) {
    int index = prefs.getInt('length');
    return index ?? 0;
  }
}
