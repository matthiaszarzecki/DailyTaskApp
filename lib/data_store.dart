import 'dart:convert';
import 'package:daily_task_app/daily_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStore {
  static Future<void> saveDailyTask(DailyTask task) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    prefs.setString('asds', taskAsJson);
  }

  static Future<DailyTask> readDailyTask(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String taskAsString = prefs.getString(key);
    Map<String, dynamic> taskAsMap = jsonDecode(taskAsString);
    DailyTask task = DailyTask.fromJson(taskAsMap);
    return task;
  }
}
