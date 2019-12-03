import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_task_app/daily_task.dart';

class DataStore {
  static const String keyLength = 'length';
  static const String prefixSingleTask = 'single_task_';

  /// Saves a single daily task to the preferences with continuing index
  static Future<void> saveDailyTask(DailyTask task) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    int length = _getLength(prefs);
    prefs.setInt(keyLength, length + 1);
    prefs.setString('$prefixSingleTask$length', taskAsJson);
    print('Saved: $prefixSingleTask$length');
  }

  // Gets all tasks from the preferences
  static Future<List<DailyTask>> getAllDailyTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DailyTask> tasks = <DailyTask>[];
    int length = _getLength(prefs);
    print('length: $length');
    for (int index = 0; index < length; index++) {
      String taskAsString = prefs.getString('$prefixSingleTask$index');
      print(taskAsString);
      Map<String, dynamic> taskAsMap = jsonDecode(taskAsString);
      DailyTask task = DailyTask.fromJson(taskAsMap);
      tasks.add(task);
    }
    return tasks;
  }

  static int _getLength(SharedPreferences prefs) {
    int index = prefs.getInt(keyLength);
    return index ?? 0;
  }

  static Future<void> removeAllSavedTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int length = _getLength(prefs);
    for (int index = 0; index < length; index++) {
      prefs.setString('$prefixSingleTask$index', null);
    }
    prefs.setInt(keyLength, null);
  }
}
