import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

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
  final List<String> intervalStrings = <String>[
    'Daily',
    'Monthly',
  ];
  DailyTask currentSelectedTask;
  int currentSelectedIndex;

  GlobalKey keyOpenIconMenu = GlobalKey();
  GlobalKey keyOpenIntervalMenu = GlobalKey();

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          _buildDeleteAllTasksButton(),
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

  Widget _buildDeleteAllTasksButton() {
    return IconButton(
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
    );
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
    setState(() {
      _dailyTasks.add(newTask);
      _cellStates.add(false);
      DataStore.saveNewDailyTask(newTask);

      // Scrolls the view to the lowest scroll position,
      // and a bit further to accomodate cell-height
      _scrollController.animateTo(
        // TODO(MZ): Only scroll when new cell would be very low on screen
        0.0, //_scrollController.position.maxScrollExtent + 150,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );

      print('Added new task: ${newTask.title}');
    });
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
      height: 64,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getStandardCellRow(
            currentTask,
            cellIsOpen,
            () => _openCellAtIndex(currentTask, index),
          ),
        ),
      ),
    );
  }

  Container _buildLargeCell(bool cellIsOpen, DailyTask currentTask, int index) {
    return Container(
      height: 310,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getExpandedCellRow(
            currentTask,
            cellIsOpen,
            () => _openCellAtIndex(currentTask, index),
            index,
          ),
        ),
      ),
    );
  }

  // TODO(MZ): Scroll to show full cell when lower cells opened
  void _openCellAtIndex(DailyTask task, int index) {
    currentSelectedTask = task;
    currentSelectedIndex = index;
    setState(() {
      // Close all cells that are not the specified cell
      for (int counter = 0; counter < _cellStates.length; counter++) {
        if (counter != index) {
          _cellStates[counter] = false;
        }
      }
      _cellStates[index] = !_cellStates[index];
    });
  }

  Icon _buildCellIcon(bool cellIsOpen) {
    return cellIsOpen ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down);
  }

  List<Widget> _getStandardCellRow(
    DailyTask currentTask,
    bool cellIsOpen,
    Function setState,
  ) {
    return <Widget>[
      ListTile(
        title: Row(
          children: <Widget>[
            const Checkbox(
              value: false,
              onChanged: null,
            ),
            Text(currentTask.title),
          ],
        ),
        leading: currentTask.getIcon(),
        trailing: IconButton(
          icon: _buildCellIcon(cellIsOpen),
          tooltip: 'Edit',
          onPressed: setState,
        ),
      ),
    ];
  }

  List<Widget> _getExpandedCellRow(
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
            key: keyOpenIconMenu,
            onPressed: () {
              _openIconMenu();
            },
            child: currentTask.getIcon(),
          ),
          OutlineButton(
            key: keyOpenIntervalMenu,
            onPressed: () {
              _openIntervalMenu();
            },
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
      // TODO(MZ): Display when a task has been last updated in nice text (1 day ago, etc)
      Text(
        'Last updated: ${currentTask.lastModified}',
        textAlign: TextAlign.left,
      ),
      ButtonBar(
        children: <Widget>[
          FlatButton(
            child: const Text('DELETE TASK'),
            color: Colors.redAccent,
            onPressed: () => _deleteTask(currentTask, index),
          ),
        ],
      ),
    ];
  }

  String _getRandomIconString() {
    return randomChoice(iconStrings);
  }

  void _deleteTask(DailyTask currentTask, int index) {
    DataStore.removeSingleTask(currentTask, index);

    setState(() {
      _dailyTasks.removeAt(index);
      _cellStates.removeAt(index);
    });

    print("Deleted Task '${currentTask.title}' at index $currentTask");
  }

  /*void _getNewRandomIcon(DailyTask currentTask, int index) {
    setState(() {
      currentTask.iconString = _getRandomIconString();
    });
    DataStore.updateSingleTask(currentTask, index);
    print('Updated Icon to ${currentTask.iconString}');
  }*/

  void _openIntervalMenu() {
    List<MenuItem> items = intervalStrings.map(
      (String currentIntervalString) {
        return MenuItem(
          title: currentIntervalString,
          image: Icon(
            MdiIcons.fromString('unity'),
            color: Colors.white,
          ),
        );
      },
    ).toList();
    PopupMenu menu = PopupMenu(
      // backgroundColor: Colors.teal,
      // lineColor: Colors.white,
      // maxColumn: 2,
      items: items,
      onClickMenu: _intervalItemClicked,
      stateChanged: _intervalStateChanged,
      onDismiss: _intervalMenuDismissed,
    );
    menu.show(widgetKey: keyOpenIntervalMenu);
  }

  void _intervalStateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void _intervalMenuDismissed() {
    print('Menu is dismissed');
  }

  void _intervalItemClicked(MenuItemProvider item) {
    _setNewIntervalForTask(
      currentSelectedTask,
      currentSelectedIndex,
      item.menuTitle,
    );
  }

  void _setNewIntervalForTask(
    DailyTask task,
    int index,
    String intervalString,
  ) {
    // TODO(MZ): Allow setting of Intervals
    //setState(() {
    //  task.iconString = iconString;
    //});
    DataStore.updateSingleTask(task, index);
    print('Updated Icon to ${task.iconString}');
  }

  // TODO(MZ): Create CellState class that contains a task and the cellstate (open, done)
  void _openIconMenu() {
    List<MenuItem> items = iconStrings.map(
      (String currentIconString) {
        return MenuItem(
          title: currentIconString,
          image: Icon(
            MdiIcons.fromString(currentIconString),
            color: Colors.white,
          ),
        );
      },
    ).toList();

    /*List<MenuItem> items = <MenuItem>[
      MenuItem(
        title: 'Copy',
        image: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Home',
        textStyle: TextStyle(fontSize: 10.0, color: Colors.tealAccent),
        image: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Mail',
        image: Icon(
          Icons.mail,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Power',
        image: Icon(
          Icons.power,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Setting',
        image: Icon(
          Icons.settings,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'PopupMenu',
        image: Icon(
          Icons.menu,
          color: Colors.white,
        ),
      )
    ];*/
    PopupMenu menu = PopupMenu(
      // backgroundColor: Colors.teal,
      // lineColor: Colors.white,
      // maxColumn: 2,
      items: items,
      onClickMenu: _iconItemClicked,
      stateChanged: _iconStateChanged,
      onDismiss: _iconMenuDismissed,
    );
    menu.show(widgetKey: keyOpenIconMenu);
  }

  void _iconStateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void _iconMenuDismissed() {
    print('Menu is dismissed');
  }

  void _iconItemClicked(MenuItemProvider item) {
    _setNewIconForTask(
      currentSelectedTask,
      currentSelectedIndex,
      item.menuTitle,
    );
  }

  void _setNewIconForTask(DailyTask task, int index, String iconString) {
    setState(() {
      task.iconString = iconString;
    });
    DataStore.updateSingleTask(task, index);
    print('Updated Icon to ${task.iconString}');
  }
}
