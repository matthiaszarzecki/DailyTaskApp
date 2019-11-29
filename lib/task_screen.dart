import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:daily_task_app/daily_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() {
    return _TaskScreenState();
  }
}

class _TaskScreenState extends State<TaskScreen> {
  final List<DailyTask> _dailyTasks = <DailyTask>[
    DailyTask(title: 'Title 0', counter: 0, icon: Icon(Icons.hot_tub)),
    DailyTask(title: 'Title 1', counter: 0, icon: Icon(Icons.hot_tub)),
    DailyTask(title: 'Title 2', counter: 0, icon: Icon(Icons.hot_tub)),
  ];

  void _addDailyTask() {
    _saveDailyTask(_dailyTasks[0]);
    _readDailyTask('asds');

    setState(
      () {
        int currentIndex = _dailyTasks.length;
        _dailyTasks.add(
          DailyTask(
            title: 'Title $currentIndex',
            counter: 0,
            icon: Icon(Icons.hot_tub),
          ),
        );
      },
    );
  }

  List<Widget> _getCells(List<DailyTask> tasks) {
    return tasks.map(
      (DailyTask currentTask) {
        return Card(
          child: ListTile(
            title: Text(currentTask.title),
            leading: currentTask.icon,
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              tooltip: 'Edit',
              onPressed: () {
                setState(
                  () {},
                );
              },
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
      ),
      body: ListView(
        children: _getCells(_dailyTasks),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDailyTask,
        tooltip: 'Add Daily Task',
        child: Icon(Icons.add),
      ),
    );
  }

  // TODO(matthiaszarzecki): Extract these into own class
  Future<void> _saveDailyTask(DailyTask task) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskAsMap = task.toJson();
    String taskAsJson = jsonEncode(taskAsMap);
    prefs.setString('asds', taskAsJson);
  }

  Future<void> _readDailyTask(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String taskAsString = prefs.getString(key);
    Map<String, dynamic> taskAsMap = jsonDecode(taskAsString);
    DailyTask task = DailyTask.fromJson(taskAsMap);
    _dailyTasks.add(task);
  }
}
