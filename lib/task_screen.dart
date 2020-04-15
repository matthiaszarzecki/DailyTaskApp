import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

import 'package:daily_task_app/cell_state.dart';
import 'package:daily_task_app/daily_task.dart';
import 'package:daily_task_app/data_store.dart';

enum TaskStatus {
  todo,
  done,
  failed,
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key key, this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  _TaskScreenState createState() {
    return _TaskScreenState();
  }
}

class _TaskScreenState extends State<TaskScreen> with WidgetsBindingObserver {
  List<CellState> _cellStates = <CellState>[];

  final List<String> iconStrings = <String>[
    'bike',
    'book',
    'cloud',
    'console-line',
    'exclamation',
    'face',
    'food-apple',
    'fruit-grapes',
    'fruit-pineapple',
    'fruit-watermelon',
    'music-clef-treble',
    'stack-overflow',
    'trumpet',
    'walk',
    'water',
    'weather-sunny',
  ];

  final List<String> intervalStrings = <String>[
    'Daily',
    'Mo-Fr',
    'Weekly',
    'Monthly',
  ];

  final double iconSize = 25;

  CellState currentlySelectedCellState;
  int currentlySelectedIndex;

  GlobalKey keyOpenIconMenu = GlobalKey();
  GlobalKey keyOpenIntervalMenu = GlobalKey();
  GlobalKey keyOpenDeleteMenu = GlobalKey();

  bool _isListSorted = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _dailyUpdateCheck();
    }
  }

  Future<void> _dailyUpdateCheck() async {
    if (await _dayLaterThanLastDailyCheck() && _isTimeOfDayLaterThan0400()) {
      DataStore.saveLastDailyCheckDate();

      for (int index = 0; index < _cellStates.length; index++) {
        CellState state = _cellStates[index];
        if (state.task.status == TaskStatus.done) {
          state.task.currentStreak += 1;
          if (state.task.currentStreak > state.task.longestStreak) {
            state.task.longestStreak = state.task.currentStreak;
          }
        } else {
          state.task.currentStreak = 0;
        }

        if (state.task.status != TaskStatus.todo) {
          state.task.status = TaskStatus.todo;
        }

        DataStore.updateSingleTask(state.task, index);
      }

      setState(() {});
    }
  }

  Future<bool> _dayLaterThanLastDailyCheck() async {
    // Get the saved DateTime for the last check from the DataStore.
    // If none exists the year 1970 will be returned.
    DateTime lastDailyCheck = await DataStore.getLastDailyCheckDate();
    // Checks if it is after the lastDailyCheck, but also that the
    // day is different, to make sure it is actually the day after.
    return DateTime.now().isAfter(lastDailyCheck) &&
        DateTime.now().day != lastDailyCheck.day;
  }

  bool _isTimeOfDayLaterThan0400() {
    return TimeOfDay.now().hour >= 4;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    _dailyUpdateCheck();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          _buildReorderListButton(),
          _buildCornerMenu(),
        ],
      ),
      body: ListView(
        children: _getCells(_cellStates),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDailyTask,
        child: Icon(Icons.add),
      ),
    );
  }

  PopupMenuButton<int> _buildCornerMenu() {
    return PopupMenuButton<int>(
      onSelected: (_) => _deleteAllTasks(),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
            value: 1,
            child: Text('Delete All Tasks'),
            textStyle: TextStyle(color: Colors.red),
          ),
        ];
      },
    );
  }

  @override
  void initState() {
    _getAllSavedTasks();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _deleteAllTasks() {
    setState(() {
      // Empty Arrays
      _cellStates = <CellState>[];
    });
    DataStore.removeAllSavedTasks();
    print('Deleted all tasks');
  }

  Widget _buildReorderListButton() {
    return !_isListSorted
        ? IconButton(
            icon: Icon(MdiIcons.sort),
            onPressed: () {
              List<CellState> newCellStates = _cellStates;
              newCellStates
                  .sort((CellState a, CellState b) => _compareCellStates(a, b));

              setState(() {
                _cellStates = newCellStates;
                _isListSorted = true;
              });
            },
          )
        : Container();
  }

  bool _checkIfListIsSorted() {
    // Copy the current list and sort it. If it equals the current list it is sorted.
    List<CellState> maybeSortedList = <CellState>[];
    maybeSortedList.addAll(_cellStates);
    maybeSortedList
        .sort((CellState a, CellState b) => _compareCellStates(a, b));

    for (int i = 0; i < _cellStates.length; i++) {
      // If status values are not the same, then the lists are not identical.
      // Abort and return false.
      if (maybeSortedList[i].task.status != _cellStates[i].task.status) {
        return false;
      }
    }
    // If the previous check runs succesfully the lists are identical. Return true.
    return true;
  }

  Icon _buildIcon(CellState cellState, double size) {
    return Icon(
      cellState.task.getIconData(),
      color: Theme.of(context).iconTheme.color,
      size: size,
    );
  }

  Future<void> _getAllSavedTasks() async {
    List<DailyTask> dailyTasks = await DataStore.getAllDailyTasks();
    List<CellState> newCellStates = dailyTasks.map(
      (DailyTask task) {
        return CellState(
          task: task,
          cellIsOpen: false,
        );
      },
    ).toList();

    newCellStates.sort((CellState a, CellState b) => _compareCellStates(a, b));

    setState(() {
      _isListSorted = true;
      _cellStates = newCellStates;
    });
  }

  /// Compares CellState's by status. Todo are up top, followed by done and failed.
  int _compareCellStates(CellState a, CellState b) {
    if (a.task.status == TaskStatus.done) {
      if (b.task.status == TaskStatus.todo) {
        // If a.task is done and b.task is todo, move a down
        return 1;
      } else if (b.task.status == TaskStatus.failed) {
        // If a.task is done and b.task is failed, move a up
        return -1;
      }
    } else if (a.task.status == TaskStatus.todo) {
      // If a.task is todo, always move a up
      return -1;
    }

    // If a.task is failed, always move a down
    return 1;
  }

  void _addDailyTask() {
    int currentIndex = _cellStates.length;

    CellState newState = CellState(
      task: DailyTask(
        title: 'New Task $currentIndex',
        iconString: _getRandomIconString(),
        interval: 'Daily',
        status: TaskStatus.todo,
        lastModified: DateTime.now(),
        currentStreak: 0,
        longestStreak: 0,
      ),
      cellIsOpen: false,
    );

    _cellStates.insert(0, newState);
    bool sortState = _checkIfListIsSorted();

    setState(() {
      _isListSorted = sortState;
    });

    DataStore.saveNewDailyTask(newState.task);
  }

  List<Widget> _getCells(List<CellState> cellStates) {
    return cellStates.map(
      (CellState currentState) {
        return _buildCell(currentState);
      },
    ).toList();
  }

  Container _buildCell(CellState cellState) {
    return cellState.cellIsOpen
        ? _buildLargeCell(cellState)
        : _buildSmallCell(cellState);
  }

  Container _buildSmallCell(CellState cellState) {
    return Container(
      height: 64,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getStandardCellRow(
            cellState,
            () => _openCellAtIndex(cellState),
          ),
        ),
      ),
    );
  }

  Container _buildLargeCell(CellState cellState) {
    return Container(
      height: 200,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getExpandedCellRow(
            cellState,
            () => _openCellAtIndex(cellState),
          ),
        ),
      ),
    );
  }

  void _openCellAtIndex(CellState cellState) {
    currentlySelectedCellState = cellState;
    currentlySelectedIndex = _cellStates.indexOf(cellState);
    setState(() {
      // Close all cells that are not the specified cell
      for (int counter = 0; counter < _cellStates.length; counter++) {
        if (counter != currentlySelectedIndex) {
          _cellStates[counter].cellIsOpen = false;
        }
      }
      _cellStates[currentlySelectedIndex].cellIsOpen =
          !_cellStates[currentlySelectedIndex].cellIsOpen;
    });
  }

  Icon _buildCellIcon(bool cellIsOpen) {
    return cellIsOpen ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down);
  }

  List<Widget> _getStandardCellRow(CellState cellState, Function openFunction) {
    int index = _cellStates.indexOf(cellState);
    return <Widget>[
      ListTile(
        leading: _buildCheckBoxOrCross(cellState, index),
        title: Row(
          children: <Widget>[
            //_buildIcon(cellState, iconSize),
            Container(
              width: 33,
              height: 33,
              child: _buildIcon(cellState, iconSize),
              //padding: const EdgeInsets.all(0.0),
            ),
            const Spacer(),
            Text(cellState.task.title),
            const Spacer(),
          ],
        ),
        trailing: IconButton(
          icon: _buildCellIcon(cellState.cellIsOpen),
          tooltip: 'Edit',
          onPressed: openFunction,
        ),
      ),
    ];
  }

  void _markTaskAsChecked(CellState cellState, int index, bool newValue) {
    cellState.task.status = newValue ? TaskStatus.done : TaskStatus.todo;
    bool sortState = _checkIfListIsSorted();
    setState(() {
      print('Update View');
      _isListSorted = sortState;
    });
    DataStore.updateSingleTask(cellState.task, index);
  }

  // TODO(MZ): Allow editing of streaks
  List<Widget> _getExpandedCellRow(
    CellState cellState,
    Function closeFunction,
  ) {
    int index = _cellStates.indexOf(cellState);
    return <Widget>[
      ListTile(
        leading: _buildCheckBoxOrCross(cellState, index),
        title: Row(
          children: <Widget>[
            //_buildIcon(cellState, iconSize),
            Container(
              width: 33,
              height: 33,
              child: OutlineButton(
                padding: const EdgeInsets.all(0.0),
                child: _buildIcon(cellState, iconSize),
                key: keyOpenIconMenu,
                onPressed: () {
                  _openIconMenu();
                },
                color: Theme.of(context).iconTheme.color,
              ),
              //padding: const EdgeInsets.all(0.0),
            ),
            const Spacer(),
            Container(
              height: 44,
              width: 200,
              // TODO(MZ): Change size to be adaptive
              child: TextField(
                obscureText: false,
                textAlign: TextAlign.center,
                maxLines: 1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: cellState.task.title,
                ),
                onChanged: (String text) => _updateTaskTitle(text),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: _buildCellIcon(cellState.cellIsOpen),
          onPressed: closeFunction,
        ),
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(),
          OutlineButton(
            onPressed: () {
              _markTaskAsFailed(cellState, index);
            },
            child: cellState.task.status == TaskStatus.failed
                ? const Text('Unmark as Failed')
                : const Text('Mark as Failed'),
          ),
          Container(),
          FlatButton(
            key: keyOpenDeleteMenu,
            child: const Text('Delete Task'),
            color: Colors.redAccent,
            onPressed: () => _openDeleteTaskmenu(),
          ),
          Container(),
        ],
      ),
      Text(
        '''
        ${_getCurrentStreakDisplay(cellState)}
        ${_getLongestStreakDisplay(cellState)}
        ${_getLastUpdatedText(cellState.task.lastModified)}
        ''',
        textScaleFactor: 1.1,
      ),
    ];
  }

  String _getCurrentStreakDisplay(CellState cellState) {
    String daysDisplay = cellState.task.currentStreak == 1 ? 'day' : 'days';
    return 'Current Streak: ${cellState.task.currentStreak} $daysDisplay';
  }

  String _getLongestStreakDisplay(CellState cellState) {
    String daysDisplay = cellState.task.currentStreak == 1 ? 'day' : 'days';
    return 'Record Streak: ${cellState.task.currentStreak} $daysDisplay';
  }

  Widget _buildCheckBoxOrCross(CellState cellState, int index) {
    if (cellState.task.status != TaskStatus.failed) {
      return Checkbox(
        value: cellState.task.status == TaskStatus.done,
        onChanged: (bool newValue) =>
            _markTaskAsChecked(cellState, index, newValue),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          MdiIcons.close,
          color: Colors.red,
          size: iconSize,
        ),
      );
    }
  }

  void _markTaskAsFailed(CellState state, int index) {
    state.task.status = state.task.status == TaskStatus.failed
        ? TaskStatus.todo
        : TaskStatus.failed;
    bool sortState = _checkIfListIsSorted();
    setState(() {
      _isListSorted = sortState;
    });

    DataStore.updateSingleTask(state.task, index);
  }

  String _getLastUpdatedText(DateTime lastModified) {
    Duration differenceToRightNow = DateTime.now().difference(lastModified);

    String returnText = '';
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
      currentlySelectedCellState.task.title = text;
    });
    DataStore.updateSingleTask(
        currentlySelectedCellState.task, currentlySelectedIndex);
    print('Updated Title to ${currentlySelectedCellState.task.title}');
  }

  String _getRandomIconString() {
    return randomChoice(iconStrings);
  }

  void _deleteTask(DailyTask currentTask, int index) {
    DataStore.removeSingleTask(currentTask, index);

    setState(() {
      _cellStates.removeAt(index);
    });

    print("Deleted Task '${currentTask.title}' at index $currentTask");
  }

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
      currentlySelectedCellState.task,
      currentlySelectedIndex,
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
      currentlySelectedCellState.task,
      currentlySelectedIndex,
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
      _deleteTask(currentlySelectedCellState.task, currentlySelectedIndex);
    } else {
      _deleteMenuDismissed();
    }
  }
}
