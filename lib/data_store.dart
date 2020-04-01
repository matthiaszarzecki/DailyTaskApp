import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_task_app/daily_task.dart';

class DataStore {
  static const String keyLength = 'length';
  static const String prefixSingleTask = 'single_task_';

  /// Saves a single daily task to the preferences with continuing index
  static Future<void> saveNewDailyTask(DailyTask task) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    int length = _getLength(prefs);
    prefs.setInt(keyLength, length + 1);
    prefs.setString('$prefixSingleTask$length', taskAsJson);
  }

  // Gets all tasks from the preferences
  static Future<List<DailyTask>> getAllDailyTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DailyTask> tasks = <DailyTask>[];
    int length = _getLength(prefs);
    for (int index = 0; index < length; index++) {
      String taskAsString = prefs.getString('$prefixSingleTask$index');
      Map<String, dynamic> taskAsJson = jsonDecode(taskAsString);
      DailyTask task = DailyTask.fromJson(taskAsJson);
      tasks.add(task);
    }
    return tasks;
  }

  /// Gets the number of saved Tasks in the preferences
  static int _getLength(SharedPreferences prefs) {
    int index = prefs.getInt(keyLength);
    return index ?? 0;
  }

  // Sets alls saved tasks (and the number of tasks) to null
  static Future<void> removeAllSavedTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int length = _getLength(prefs);
    for (int index = 0; index < length; index++) {
      prefs.setString('$prefixSingleTask$index', null);
    }
    prefs.setInt(keyLength, null);
  }

  static Future<void> removeSingleTask(DailyTask task, int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int length = _getLength(prefs);
    // Find saved task at Index
    for (int counter = index + 1; counter < length; counter++) {
      // More all SUBSEQUENT TASKS down one step, thus overwriting the specified task
      int adaptedIndex = counter - 1;
      Map<String, dynamic> taskAsMap = task.toJson();
      String taskAsJson = jsonEncode(taskAsMap);
      prefs.setString('$prefixSingleTask$adaptedIndex', taskAsJson);
    }

    // Set Index to -1, and save it
    prefs.setInt(keyLength, length - 1);

    // There is still technically a task saved at the previous length-index, but will not be accessed
  }

  static Future<void> updateSingleTask(DailyTask task, int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Saves new task to specified index, overwriting the old one
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    prefs.setString('$prefixSingleTask$index', taskAsJson);
    print('Updated Task! ${task.toString()}');
  }
}
