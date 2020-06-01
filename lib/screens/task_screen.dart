import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

import 'package:daily_task_app/constants/icons.dart';
import 'package:daily_task_app/enums/task_status.dart';
import 'package:daily_task_app/models/cell_state.dart';
import 'package:daily_task_app/models/daily_task.dart';
import 'package:daily_task_app/utilities/comparison.dart';
import 'package:daily_task_app/utilities/data_store.dart';
import 'package:daily_task_app/utilities/date_time_parser.dart';

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

  final List<String> intervalStrings = <String>[
    'Daily',
    'Mo-Fr',
    'Weekly',
    'Monthly',
  ];

  final double iconSize = 25;
  DateTime currentDateTime;
  int dateTimeOffsetInDays = 0;

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
    print('#### Daily Update Check ####');

    if (await _shouldResetHappen()) {
      DataStore.saveNextResetDateTime(dateTimeOffsetInDays);

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

  /// Checks if the current time is after the next scheduled daily reset.
  Future<bool> _shouldResetHappen() async {
    currentDateTime = DateTime.now().add(Duration(days: dateTimeOffsetInDays));
    DateTime resetTime = await DataStore.getNextResetDateTime();
    bool shouldReset = currentDateTime.isAfter(resetTime);
    print('It is $currentDateTime. Next Reset at $resetTime, Should Reset: $shouldReset');
    return shouldReset;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    // showFloatingActionButton is used to hide the button when a keyboard appears on-screen
    final bool showFloatingActionButton =
        MediaQuery.of(context).viewInsets.bottom == 0.0;

    PopupMenu.context = context;
    _dailyUpdateCheck();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          _buildCornerMenu(),
        ],
        centerTitle: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFloatingActionButton
          ? FloatingActionButton.extended(
              onPressed: _addDailyTask,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).iconTheme.color,
        notchMargin: 6.0,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(
            side: BorderSide(),
          ),
        ),
        child: Container(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                color: Colors.white,
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationVersion: '0.1.0',
                    applicationIcon: const FlutterLogo(),
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'This is where I\'d put more information about '
                          'this app, if there was anything interesting to say.',
                        ),
                      ),
                    ],
                  );
                },
              ),
              _buildReorderListButton(),
            ],
          ),
        ),
      ),
      body: ListView(
        children: _getCells(_cellStates),
      ),
    );
  }

  PopupMenuButton<int> _buildCornerMenu() {
    return PopupMenuButton<int>(
      onSelected: (int value) {
        if (value == 1) {
          _deleteAllTasks();
        } else {
          _advanceToNextDay();
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
            value: 0,
            child: Text('Go to Next Day'),
            textStyle: TextStyle(color: Colors.green),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: Text('Delete All Tasks'),
            textStyle: TextStyle(color: Colors.red),
          ),
        ];
      },
    );
  }

  void _advanceToNextDay() {
    setState(() {
      dateTimeOffsetInDays += 1;
    });
  }

  @override
  void initState() {
    _getAllSavedTasks();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _deleteAllTasks() {
    setState(() {
      // Empty the Array of cellStates
      _cellStates = <CellState>[];
    });
    DataStore.removeAllSavedTasks();
    print('Deleted all tasks');
  }

  /// Builds a button to auto-sort the list of tasks if the list is
  /// not sorted, or an empty Container if it is sorted.
  Widget _buildReorderListButton() {
    return !_isListSorted
        ? FlatButton(
            child: const Text('Sort'),
            textColor: Colors.white,
            onPressed: () {
              List<CellState> newCellStates = _cellStates;
              newCellStates
                  .sort((CellState a, CellState b) => compareCellStates(a, b));

              setState(() {
                _cellStates = newCellStates;
                _isListSorted = true;
              });
            },
          )
        : Container();
  }

  // TODO(MZ): Sort-Button shows up irregularly
  bool _checkIfListIsSorted() {
    // Copy the current list and sort it. If it equals the current list it is sorted.
    List<CellState> maybeSortedList = <CellState>[];
    maybeSortedList.addAll(_cellStates);
    maybeSortedList.sort((CellState a, CellState b) => compareCellStates(a, b));

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

    newCellStates.sort((CellState a, CellState b) => compareCellStates(a, b));

    setState(() {
      _isListSorted = true;
      _cellStates = newCellStates;
    });
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
      height: 185,
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
    return cellIsOpen
        ? const Icon(Icons.arrow_drop_up)
        : const Icon(Icons.arrow_drop_down);
  }

  List<Widget> _getStandardCellRow(CellState cellState, Function openFunction) {
    int index = _cellStates.indexOf(cellState);
    return <Widget>[
      ListTile(
        leading: _buildCheckBoxOrCross(cellState, index),
        // InkWell allows the entire space to be clickable
        title: InkWell(
          onTap: openFunction,
          child: Row(
            children: <Widget>[
              Container(
                width: 33,
                height: 33,
                child: _buildIcon(cellState, iconSize),
              ),
              const Spacer(),
              Text(cellState.task.title),
              const Spacer(),
            ],
          ),
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
    TaskStatus newStatus = newValue ? TaskStatus.done : TaskStatus.todo;
    bool sortState = _checkIfListIsSorted();
    setState(() {
      cellState.task.status = newStatus;
      _isListSorted = sortState;
      print('#### Updated View ####');
    });
    DataStore.updateSingleTask(cellState.task, index);
  }

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
            ),
            const Spacer(),
            Container(
              height: 44,
              // Adapts width to fix the available space
              width: MediaQuery.of(context).size.width - 225,
              margin: const EdgeInsets.all(0.0),
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
      _getStreakTexts(cellState),
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
    ];
  }

  Text _getStreakTexts(CellState cellState) {
    return Text(
      '''
        ${_getCurrentStreakDisplay(cellState)}
        ${_getLongestStreakDisplay(cellState)}
        ${getLastUpdatedText(cellState.task.lastModified)}''',
      textScaleFactor: 1.1,
    );
  }

  String _getCurrentStreakDisplay(CellState cellState) {
    String daysDisplay = cellState.task.currentStreak == 1 ? 'day' : 'days';
    return 'Current Streak: ${cellState.task.currentStreak} $daysDisplay';
  }

  String _getLongestStreakDisplay(CellState cellState) {
    String daysDisplay = cellState.task.currentStreak == 1 ? 'day' : 'days';
    return 'Record Streak: ${cellState.task.currentStreak} $daysDisplay';
  }

  /// Builds a checkbox that can be marked as "done", or a Red Cross when a task is marked as "failed".
  Widget _buildCheckBoxOrCross(CellState cellState, int index) {
    if (cellState.task.status != TaskStatus.failed) {
      bool checkBoxValue = cellState.task.status == TaskStatus.done;
      return Checkbox(
        value: checkBoxValue,
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

  void _updateTaskTitle(String text) {
    setState(() {
      currentlySelectedCellState.task.title = text;
    });
    // TODO(MZ): Something is wrong with index-based updating & saving. Find it and fix it.
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

  /*
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
  }*/

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

    // Hide keyboard when opening icon-menu
    FocusScope.of(context).unfocus();

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
        title: 'Keep Task.',
        image: Icon(
          MdiIcons.fromString('arrow-left-thick'),
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Delete!',
        image: Icon(
          MdiIcons.fromString('delete'),
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
