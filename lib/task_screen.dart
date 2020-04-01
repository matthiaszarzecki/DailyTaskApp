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
          _buildDeleteAllTasksButton(),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        reverse: false, // reverses list
        children: _getCells(_cellStates),
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

    setState(() {
      _cellStates = newCellStates;
    });
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
      ),
      cellIsOpen: false,
    );

    setState(() {
      _cellStates.add(newState);
      DataStore.saveNewDailyTask(newState.task);

      // TODO(MZ): Add cells at top of list
      print('Added new task: ${newState.task.title}');
    });
  }

  // Builds the cells. Is called on screen-load and cell-addition
  List<Widget> _getCells(List<CellState> cellStates) {
    return cellStates.map(
      (CellState currentState) {
        int index = cellStates.indexOf(currentState);
        return _buildCell(currentState, index);
      },
    ).toList();
  }

  // TODO(MZ): Get Index out at a later point? - figure out where it is needed!
  Container _buildCell(CellState cellState, int index) {
    return cellState.cellIsOpen
        ? _buildLargeCell(cellState, index)
        : _buildSmallCell(cellState, index);
  }

  Container _buildSmallCell(CellState cellState, int index) {
    return Container(
      height: 64,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getStandardCellRow(
            cellState,
            () => _openCellAtIndex(cellState, index),
          ),
        ),
      ),
    );
  }

  Container _buildLargeCell(CellState cellState, int index) {
    return Container(
      height: 310,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getExpandedCellRow(
            cellState,
            () => _openCellAtIndex(cellState, index),
            index,
          ),
        ),
      ),
    );
  }

  void _openCellAtIndex(CellState cellState, int index) {
    currentlySelectedCellState = cellState;
    currentlySelectedIndex = index;
    setState(() {
      // Close all cells that are not the specified cell
      for (int counter = 0; counter < _cellStates.length; counter++) {
        if (counter != index) {
          _cellStates[counter].cellIsOpen = false;
        }
      }
      _cellStates[index].cellIsOpen = !_cellStates[index].cellIsOpen;
    });
  }

  Icon _buildCellIcon(bool cellIsOpen) {
    return cellIsOpen ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down);
  }

  List<Widget> _getStandardCellRow(CellState cellState, Function openFunction) {
    int index = _cellStates.indexOf(cellState);
    return <Widget>[
      ListTile(
        title: Row(
          children: <Widget>[
            Checkbox(
              value: cellState.task.markedAsDone ?? false,
              onChanged: (_) => _markTaskAsChecked(cellState, index),
            ),
            Text(cellState.task.title),
          ],
        ),
        leading: cellState.task.getIcon(),
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
    Function setState,
    int index,
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
        leading: cellState.task.getIcon(),
        trailing: IconButton(
          icon: _buildCellIcon(cellState.cellIsOpen),
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
            child: cellState.task.getIcon(),
          ),
          OutlineButton(
            key: keyOpenIntervalMenu,
            onPressed: () {
              _openIntervalMenu();
            },
            child: Text(cellState.task.interval),
          ),
          OutlineButton(
            onPressed: () {},
            child: const Text('+1'),
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
    print(lastModified);
    return 'asdsa';

    // TODO(MZ): Bug: lastModified-value is null, somehow
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

  // TODO(MZ): Unify cellState parameter / global cellState
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
