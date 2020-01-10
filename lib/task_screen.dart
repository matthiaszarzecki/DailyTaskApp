import 'package:flutter/material.dart';

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

// TODO(mz): add new screen to show details of tasks

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(
                () {
                  _dailyTasks = <DailyTask>[];
                  DataStore.removeAllSavedTasks();
                },
              );
            },
          ),
        ],
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
    int currentIndex = _dailyTasks.length;
    DailyTask newTask = DailyTask(
      title: 'Task $currentIndex',
      counter: 0,
      iconString: 'unity',
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
            leading: currentTask.getIcon(),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              tooltip: 'Edit',
              onPressed: () {
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (_) {
                      return TaskDetailScreen();
                    },
                  ),
                );
                /*setState(
                  () {},
                );*/
              },
            ),
          ),
        );
      },
    ).toList();
  }
}

class TaskDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
