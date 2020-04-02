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

class _TaskScreenState extends State<TaskScreen> {
  List<CellState> _cellStates = <CellState>[];
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

  CellState currentlySelectedCellState;
  int currentlySelectedIndex;

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
          _buildReorderListButton(),
          _buildDeleteAllTasksButton(),
          
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

  @override
  void initState() {
    _getAllSavedTasks();
    super.initState();
  }

  Widget _buildDeleteAllTasksButton() {
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        setState(
          () {
            // Empty Arrays
            _cellStates = <CellState>[];
            DataStore.removeAllSavedTasks();
            print('Deleted all tasks');
          },
        );
      },
    );
  }

  Widget _buildReorderListButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        List<CellState> newCellStates = _cellStates;
        newCellStates
            .sort((CellState a, CellState b) => compareCellStates(a, b));

        setState(() {
          _cellStates = newCellStates;
        });
      },
    );
  }
  // TODO(MZ): Remove checkmarks daily at 0300

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
      _cellStates = newCellStates;
    });
  }

  /// Compares CellState's by markedAsDone parameter, sending "done" tasks back
  int compareCellStates(CellState a, CellState b) {
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
        counter: 0,
        iconString: _getRandomIconString(),
        interval: 'Daily',
        markedAsDone: false,
        lastModified: DateTime.now(),
      ),
      cellIsOpen: false,
    );

    setState(() {
      _cellStates.insert(0, newState);
      //_cellStates.add(newState);
      print('Added new task: ${newState.task.title}');
    });

    DataStore.saveNewDailyTask(newState.task);
  }

  // Builds the cells. Is called on screen-load and cell-addition
  List<Widget> _getCells(List<CellState> cellStates) {
    return cellStates.map(
      (CellState currentState) {
        //int index = cellStates.indexOf(currentState);
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
      height: 310,
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
        leading: cellState.task.getIcon(Colors.green[200]),
        title: Row(
          children: <Widget>[
            Checkbox(
              value: cellState.task.markedAsDone ?? false,
              onChanged: (_) => _markTaskAsChecked(cellState, index),
            ),
            Text(cellState.task.title),
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
    setState(() {
      cellState.task.markedAsDone = !cellState.task.markedAsDone;
    });
    DataStore.updateSingleTask(cellState.task, index);
  }

  List<Widget> _getExpandedCellRow(
    CellState cellState,
    Function closeFunction,
  ) {
    return <Widget>[
      ListTile(
        title: TextField(
          obscureText: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: cellState.task.title,
          ),
          onChanged: (String text) => _updateTaskTitle(text),
        ),
        leading: OutlineButton(
          key: keyOpenIconMenu,
          onPressed: () {
            openIconMenu(iconStrings, keyOpenIconMenu);
          },
          child: cellState.task.getIcon(Colors.green[200]),
        ),
        trailing: IconButton(
          icon: _buildCellIcon(cellState.cellIsOpen),
          onPressed: closeFunction,
        ),
      ),
      // TOOD(MZ): Remove +1 button
      ButtonBar(
        children: <Widget>[
          OutlineButton(
            key: keyOpenIntervalMenu,
            onPressed: () {
              _openIntervalMenu();
            },
            child: Text(cellState.task.interval),
          ),
        ],
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
        _getLastUpdatedText(cellState.task.lastModified),
        textAlign: TextAlign.left,
      ),
      ButtonBar(
        children: <Widget>[
          FlatButton(
            key: keyOpenDeleteMenu,
            child: const Text('DELETE TASK'),
            color: Colors.redAccent,
            onPressed: () => _openDeleteTaskmenu(),
          ),
        ],
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
