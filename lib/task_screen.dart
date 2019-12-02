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
  final List<DailyTask> _dailyTasks = <DailyTask>[
    DailyTask(title: 'Title 0', counter: 0, icon: Icon(MdiIcons.sword)),
    DailyTask(title: 'Title 1', counter: 0, icon: Icon(MdiIcons.swordCross)),
    DailyTask(title: 'Title 2', counter: 0, icon: Icon(MdiIcons.shipWheel)),
  ];

  void _addDailyTask() {
    DataStore.saveDailyTask(_dailyTasks[0]);
    DataStore.readDailyTask('asds');

    setState(
      () {
        int currentIndex = _dailyTasks.length;
        _dailyTasks.add(
          DailyTask(
            title: 'Title $currentIndex',
            counter: 0,
            icon: Icon(MdiIcons.unity),
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
}
