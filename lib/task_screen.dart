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
                  // Empty Arrays
                  _dailyTasks = <DailyTask>[];
                  _cellStates = <bool>[];
                  DataStore.removeAllSavedTasks();
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        reverse: false, // Reverses list
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
  List<bool> _cellStates = <bool>[];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getAllSavedTasks();
    super.initState();
  }

  Future<void> getAllSavedTasks() async {
    _dailyTasks = await DataStore.getAllDailyTasks();
    _cellStates = List<bool>.filled(
      _dailyTasks.length,
      false,
      growable: true,
    );
    setState(
      () {},
    );
  }

  void _addDailyTask() {
    int currentIndex = _dailyTasks.length;
    DailyTask newTask = DailyTask(
      title: 'Task $currentIndex',
      counter: 0,
      // TODO(MZ): Add random icon
      iconString: 'unity',
    );
    setState(
      () {
        _dailyTasks.add(newTask);
        _cellStates.add(false);
        DataStore.saveDailyTask(newTask);

        // TODO(MZ): Figure out scrolling to newest entry
        _scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  List<Widget> _getCells(List<DailyTask> tasks) {
    return tasks.map(
      (DailyTask currentTask) {
        int index = tasks.indexOf(currentTask);
        bool cellIsOpen = _cellStates[index];
        return Container(
          height: cellIsOpen ? 300 : 64, //If true, set bigger cell
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _getChildren(
                currentTask,
                cellIsOpen,
                () {
                  setState(
                    () {
                      // Open Cell
                      _cellStates[index] = !cellIsOpen;
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    ).toList();
  }
}

Icon _buildCellIcon(bool cellIsOpen) {
  return cellIsOpen ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down);
}

// Should this have state?
List<Widget> _getChildren(
    DailyTask currentTask, bool cellIsOpen, Function setState) {
  return <Widget>[
    ListTile(
      title: Text(currentTask.title),
      leading: currentTask.getIcon(),
      trailing: IconButton(
        icon: _buildCellIcon(cellIsOpen),
        tooltip: 'Edit',
        onPressed: setState(),
      ),
    ),
  ];
}
