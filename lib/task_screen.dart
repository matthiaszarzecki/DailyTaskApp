import 'package:flutter/material.dart';

import 'package:daily_task_app/daily_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<DailyTask> _dailyTasks = <DailyTask>[
    DailyTask(title: 'Title 0', counter: 0, icon: Icon(Icons.hot_tub)),
    DailyTask(title: 'Title 1', counter: 0, icon: Icon(Icons.hot_tub)),
    DailyTask(title: 'Title 2', counter: 0, icon: Icon(Icons.hot_tub)),
  ];

  void _addDailyTask() {
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

  Future<void> _read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String key = 'my_int_key';
    final int value = prefs.getInt(key) ?? 0;
    print('read: $value');
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const String key = 'my_int_key';
    const int value = 42;
    prefs.setInt(key, value);
    print('saved $value');
  }
}
