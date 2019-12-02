import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:daily_task_app/daily_task.dart';
import 'package:daily_task_app/data_store.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() {
    return _TaskScreenState();
  }
}

class _TaskScreenState extends State<TaskScreen> {
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

  // TODO(matthiaszarzecki): Read out all saved tasks on startup
  List<DailyTask> _dailyTasks = <DailyTask>[];

  @override
  void initState() {
    getAllSavedTasks();
    super.initState();
  }

  Future<void> getAllSavedTasks() async {
    _dailyTasks = await DataStore.getAllDailyTasks();
    setState(
      () {},
    );
  }

  void _addDailyTask() {
    //DataStore.readDailyTask('single_task 01');
    int currentIndex = _dailyTasks.length;
    DailyTask newTask = DailyTask(
      title: 'Title $currentIndex',
      counter: 0,
      icon: Icon(MdiIcons.unity),
    );
    setState(
      () {
        _dailyTasks.add(newTask);
        DataStore.saveDailyTask(newTask);
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
}
