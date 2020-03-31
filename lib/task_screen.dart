import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

import 'package:daily_task_app/cell_state.dart';
import 'package:daily_task_app/daily_task.dart';
import 'package:daily_task_app/data_store.dart';
//import 'package:daily_task_app/intervals.dart';
//import 'package:daily_task_app/popup_icon_menu.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() {
    return _TaskScreenState();
  }
}



class _TaskScreenState extends State<TaskScreen> {
  // TODO(MZ): Replace these with CellState class that encompasses _dailyTasks & _cellStates
  List<DailyTask> _dailyTasks = <DailyTask>[];
  List<bool> _cellStates = <bool>[];

  List<CellState> _cellStatesComplicated = <CellState>[];

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
  GlobalKey keyOpenDeleteMenu = GlobalKey();

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

  // TODO(MZ): Allow setting of checkmarks
  // TODO(MZ): Remove checkmarks daily at 0300

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
      interval: 'Daily',
    );
    setState(() {
      _dailyTasks.add(newTask);
      _cellStates.add(false);
      DataStore.saveNewDailyTask(newTask);

      // Scrolls the view to the lowest scroll position,
      // and a bit further to accomodate cell-height
      _scrollController.animateTo(
        // TODO(MZ): Remove scrolling - add cells at top of list
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

  // TODO(MZ): Alternatively add cells at the top of list
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
              openIconMenu(iconStrings, keyOpenIconMenu);
            },
            child: currentTask.getIcon(),
          ),
          OutlineButton(
            key: keyOpenIntervalMenu,
            onPressed: () {
              _openIntervalMenu();
            },
            child: Text(currentTask.interval),
          ),
          OutlineButton(
            onPressed: () {},
            child: const Text('+1'),
          ),
        ],
      ),
      TextField(
        obscureText: false,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: currentTask.title,
        ),
        onChanged: (String text) => _updateTaskTitle(text),
      ),
      const Text(
        'Current Streak: 13 Days',
        textAlign: TextAlign.right,
      ),
      const Text(
        'Record Streak: 24 Days',
        textAlign: TextAlign.left,
      ),
      Text(
        //'Last updated: ${currentTask.lastModified}',
        _getLastUpdatedText(currentTask.lastModified),
        textAlign: TextAlign.left,
      ),
      ButtonBar(
        children: <Widget>[
          FlatButton(
            key: keyOpenDeleteMenu,
            child: const Text('DELETE TASK'),
            color: Colors.redAccent,
            //onPressed: () => _deleteTask(currentTask, index),
            onPressed: () => _openDeleteTaskmenu(),
          ),
        ],
      ),
    ];
  }

  // TODO(MZ): Bug: Delete task, add new task, delete new task in same slot again

  String _getLastUpdatedText(DateTime lastModified) {
    Duration differenceToRightNow = DateTime.now().difference(lastModified);
    String returnText;
    if (differenceToRightNow > const Duration(days: 2)) {
      returnText = '2 Days ago';
    } else if (differenceToRightNow > const Duration(days: 1)) {
      returnText = '1 Day ago';
    } else {
      returnText = 'Less than 1 Day ago';
    }
    return 'Last Updated: $returnText';
  }

  void _updateTaskTitle(String text) {
    setState(() {
      currentSelectedTask.title = text;
    });
    DataStore.updateSingleTask(currentSelectedTask, currentSelectedIndex);
    print('Updated Title to ${currentSelectedTask.title}');
  }

  String _getRandomIconString() {
    return randomChoice(iconStrings);
  }

  // TODO(MZ): Replace title of open cell with textfield

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
    setState(() {
      task.interval = intervalString;
    });
    DataStore.updateSingleTask(task, index);
    print('Updated Icon to ${task.iconString}');
  }

  void openIconMenu(List<String> iconStrings, GlobalKey menuKey) {
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

    PopupMenu menu = PopupMenu(
      // backgroundColor: Colors.teal,
      // lineColor: Colors.white,
      // maxColumn: 2,
      items: items,
      onClickMenu: _iconItemClicked,
      stateChanged: _iconStateChanged,
      onDismiss: _iconMenuDismissed,
    );
    menu.show(widgetKey: menuKey);
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

  // TODO(MZ): Does this class need a state for setState to work?
  void _setNewIconForTask(DailyTask task, int index, String iconString) {
    setState(() {
      task.iconString = iconString;
    });
    DataStore.updateSingleTask(task, index);
    print('Updated Icon to ${task.iconString}');
  }

  void _openDeleteTaskmenu() {
    List<MenuItem> items = <MenuItem>[
      MenuItem(
        title: 'Delete',
        image: Icon(
          MdiIcons.fromString('unity'),
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'No. Go Back.',
        image: Icon(
          MdiIcons.fromString('unity'),
          color: Colors.white,
        ),
      ),
    ];
    PopupMenu menu = PopupMenu(
      items: items,
      onClickMenu: _deleteMenuClicked,
      stateChanged: _deleteMenuChanged,
      onDismiss: _deleteMenuDismissed,
    );
    menu.show(widgetKey: keyOpenDeleteMenu);
  }

  void _deleteMenuChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void _deleteMenuDismissed() {
    print('Menu is dismissed');
  }

  void _deleteMenuClicked(MenuItemProvider item) {
    if (item.menuTitle == 'Delete') {
      // DELETE TASK
      _deleteTask(currentSelectedTask, currentSelectedIndex);
    } else {
      // dismiss menu
      _deleteMenuDismissed();
    }
  }
}
