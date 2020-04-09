import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

import 'package:daily_task_app/cell_state.dart';
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

class _TaskScreenState extends State<TaskScreen> with WidgetsBindingObserver {
  List<CellState> _cellStates = <CellState>[];
  final List<String> iconStrings = <String>[
    'unity',
    'adobe',
    'airplane-off',
    'battery-70',
  ];
  final List<String> intervalStrings = <String>[
    'Daily',
    'Mo-Fr',
    'Weekly',
    'Monthly',
  ];

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

  // TODO(MZ): Add Mark Task as Failed Button
  // TODO(MZ): Change markedAsDone to Status that can take 3 statuses

  void _dailyUpdateCheck() {
    // TODO(MZ): Remove checkmarks daily at 0300 in Resume AND Build

    if (_dayLaterThanLastDailyCheck() && _isTimeOfDayLaterThan0300()) {
      for (int index = 0; index < _cellStates.length; index++) {
        CellState state = _cellStates[index];
        if (state.task.markedAsDone) {
          state.task.markedAsDone = false;
          state.task.currentStreak += 1;
          if (state.task.currentStreak > state.task.longestStreak) {
            state.task.longestStreak = state.task.currentStreak;
          }
        } else {
          state.task.currentStreak = 0;
        }

        DataStore.updateSingleTask(state.task, 0);
      }

      //lastDailyCheck = DateTime.now();
      //Set Pref for lastDailyCheck
    }

    /*
    Check on app-show {
      if (dayLaterThanLastDailyCheck() && isTimeOfDayLaterThan0300()) {
        tasks.forEach((CellState state) {
          if (state.task.markedAsDone) {
            state.task.markedAsDone = false;
            state.task.currentStreak += 1;
            if (state.task.streak > state.task.longestStreak) {
              state.task.longestStreak = state.task.currentStreak;
            }
          } else {
            state.task.currentStreak = 0;
          }

          DataStore.saveTask(state.task);
        });

        lastDailyCheck = DateTime.now();
        Set Pref for lastDailyCheck
      }
    }

    bool _dayLaterThanLastDailyCheck() {
      DateTime lastDailyCheck = DataStore.getLastDailyCheckDate;

      return true
    }

    bool _isTimeOfDayLaterThan0300() {
      return true
    }
    */
    print('Daily Update Check');
  }

  bool _dayLaterThanLastDailyCheck() {
    // TODO(MZ): Add function that checks if it is on a later day than the last checks, then sets the current date
    //DateTime lastDailyCheck = DataStore.getLastDailyCheckDate;
    return false;
  }

  bool _isTimeOfDayLaterThan0300() {
    return TimeOfDay.now().hour >= 3;
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
    setState(
      () {
        // Empty Arrays
        _cellStates = <CellState>[];
      },
    );
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
      // If markedAsDone values are not the same, then the lists are not identical.
      // Abort and return false.
      if (maybeSortedList[i].task.markedAsDone !=
          _cellStates[i].task.markedAsDone) {
        return false;
      }
    }
    // If the previous check runs succesfully the lists are identical. Return true.
    return true;
  }

  Icon _buildIcon(CellState cellState, double size) {
    return Icon(
      cellState.task.getIconData(),
      color: Colors.green[200],
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

  /// Compares CellState's by markedAsDone parameter, sending "done" tasks back
  int _compareCellStates(CellState a, CellState b) {
    if (a.task.markedAsDone && !b.task.markedAsDone) {
      return 1;
    } else if (!a.task.markedAsDone && b.task.markedAsDone) {
      return -1;
    }
    return 0;
  }

  void _addDailyTask() {
    int currentIndex = _cellStates.length;

    CellState newState = CellState(
      task: DailyTask(
        title: 'Task $currentIndex',
        iconString: _getRandomIconString(),
        interval: 'Daily',
        markedAsDone: false,
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
        leading: Checkbox(
          value: cellState.task.markedAsDone ?? false,
          onChanged: (_) => _markTaskAsChecked(cellState, index),
        ),
        title: Row(
          children: <Widget>[
            _buildIcon(cellState, 25),
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

  void _markTaskAsChecked(CellState cellState, int index) {
    cellState.task.markedAsDone = !cellState.task.markedAsDone;
    bool sortState = _checkIfListIsSorted();
    setState(() {
      print('Update View');
      _isListSorted = sortState;
    });
    DataStore.updateSingleTask(cellState.task, index);
  }

  List<Widget> _getExpandedCellRow(
    CellState cellState,
    Function closeFunction,
  ) {
    return <Widget>[
      ListTile(
        leading: Checkbox(
          value: cellState.task.markedAsDone ?? false,
          onChanged: (_) => _markTaskAsChecked(cellState, 0),
        ),
        title: Row(
          children: <Widget>[
            _buildIcon(cellState, 25),
            const Spacer(),
            Container(
              height: 44,
              width: 200,
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
          OutlineButton(
            key: keyOpenIconMenu,
            onPressed: () {
              _openIntervalMenu();
            },
            child: Text('Icon: ${cellState.task.iconString}'),
          ),
          Container(),
          /*OutlineButton(
            key: keyOpenIntervalMenu,
            onPressed: () {
              _openIntervalMenu();
            },
            child: Text('Interval: ${cellState.task.interval}'),
          ),
          Container(),*/
          FlatButton(
            key: keyOpenDeleteMenu,
            child: const Text('DELETE TASK'),
            color: Colors.redAccent,
            onPressed: () => _openDeleteTaskmenu(),
          ),
        ],
      ),
      Text(
        'Current Streak: ${cellState.task.currentStreak} days',
        textAlign: TextAlign.right,
      ),
      Text(
        'Longest Streak: ${cellState.task.longestStreak} days',
        textAlign: TextAlign.left,
      ),
      Text(
        _getLastUpdatedText(cellState.task.lastModified),
        textAlign: TextAlign.left,
      ),
    ];
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

  void _openIconMenu(List<String> iconStrings, GlobalKey menuKey) {
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
