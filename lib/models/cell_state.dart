import 'package:daily_task_app/models/daily_task.dart';

/// The CellState wraps around a DailyTask to also tell if a cell if opened.
class CellState {
  CellState({
    this.task,
    this.cellIsOpen,
  });

  DailyTask task;
  bool cellIsOpen;
}
