import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';

import 'package:daily_task_app/daily_task.dart';
import 'package:daily_task_app/data_store.dart';
import 'package:daily_task_app/intervals.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() {
    return _TaskScreenState();
  }
}

class _TaskScreenState extends State<TaskScreen> {
  List<DailyTask> _dailyTasks = <DailyTask>[];
  List<bool> _cellStates = <bool>[];
  final ScrollController _scrollController = ScrollController();
  final List<String> iconStrings = <String>[
    'unity',
    'adobe',
    'airplane-off',
    'battery-70',
  ];

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
                  print('Deleted all tasks');
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
      iconString: _getRandomIconString(),
    );
    setState(
      () {
        _dailyTasks.add(newTask);
        _cellStates.add(false);
        DataStore.saveNewDailyTask(newTask);

        // TODO(MZ): Figure out scrolling to newest entry
        _scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );

        print('Added new task: ${newTask.title}');
      },
    );
  }

  // Builds the cells. Is called on screen-load and cell-addition
  List<Widget> _getCells(List<DailyTask> tasks) {
    return tasks.map(
      (DailyTask currentTask) {
        int index = tasks.indexOf(currentTask);
        bool cellIsOpen = _cellStates[index];
        return _buildCell(cellIsOpen, currentTask, index);
      },
    ).toList();
  }

  Container _buildCell(bool cellIsOpen, DailyTask currentTask, int index) {
    return cellIsOpen
        ? _buildLargeCell(cellIsOpen, currentTask, index)
        : _buildSmallCell(cellIsOpen, currentTask, index);
  }

  Container _buildSmallCell(bool cellIsOpen, DailyTask currentTask, int index) {
    return Container(
      height: 64, //If true, set bigger cell
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getStandardCellRow(
            currentTask,
            cellIsOpen,
            () => _openCellAtIndex(index),
          ),
        ),
      ),
    );
  }

  Container _buildLargeCell(bool cellIsOpen, DailyTask currentTask, int index) {
    return Container(
      height: 300, //If true, set bigger cell
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getExpandewdCellRow(
            currentTask,
            cellIsOpen,
            () => _openCellAtIndex(index),
            index,
          ),
        ),
      ),
    );
  }

  void _openCellAtIndex(int index) {
    setState(
      () {
        _cellStates[index] = !_cellStates[index];
      },
    );
  }

  Icon _buildCellIcon(bool cellIsOpen) {
    return cellIsOpen ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down);
  }

  // TODO(MZ): Allow Changing of icons
  // TODO(MZ): Close all other cells when opening one
  List<Widget> _getStandardCellRow(
    DailyTask currentTask,
    bool cellIsOpen,
    Function setState,
  ) {
    return <Widget>[
      ListTile(
        title: Text(currentTask.title),
        leading: currentTask.getIcon(),
        trailing: IconButton(
          icon: _buildCellIcon(cellIsOpen),
          tooltip: 'Edit',
          onPressed: setState,
        ),
      ),
    ];
  }

  List<Widget> _getExpandewdCellRow(
    DailyTask currentTask,
    bool cellIsOpen,
    Function setState,
    int index,
  ) {
    return <Widget>[
      ListTile(
        title: Text(currentTask.title),
        leading: currentTask.getIcon(),
        trailing: IconButton(
          icon: _buildCellIcon(cellIsOpen),
          tooltip: 'Edit',
          onPressed: setState,
        ),
      ),
      ButtonBar(
        children: <Widget>[
          OutlineButton(
            onPressed: () {
              _getNewIcon(currentTask, index);
            },
            child: currentTask.getIcon(),
          ),
          OutlineButton(
            onPressed: () {},
            child: Text(intervals.daily.toString()),
          ),
          OutlineButton(
            onPressed: () {},
            child: const Text('+1'),
          ),
        ],
      ),
      TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: currentTask.title,
        ),
      ),
      const Text(
        'Current Streak: 13 Days',
        textAlign: TextAlign.right,
      ),
      const Text(
        'Record Streak: 24 Days',
        textAlign: TextAlign.left,
      ),
      ButtonBar(
        children: <Widget>[
          FlatButton(
            child: const Text('DELETE TASK'),
            color: Colors.redAccent,
            onPressed: () {
              _deleteTask(currentTask, index);
            },
          ),
        ],
      ),
    ];
  }

  String _getRandomIconString() {
    return randomChoice(iconStrings);
  }

  void _deleteTask(DailyTask currentTask, int index) {
    // TODO(MZ): Delete Task
    // Remove task from task-arrays
    //_dailyTasks = <DailyTask>[];
    //_cellStates = <bool>[];

    DataStore.removeSingleTask(currentTask, index);
    print("Deleted Task '${currentTask.title}' at index $currentTask");
  }

  void _getNewIcon(DailyTask currentTask, int index) {
    setState(() {
      currentTask.iconString = _getRandomIconString();
    });
    DataStore.updateSingleTask(currentTask, index);
    print('Updated Icon to ${currentTask.iconString}');
  }
}
