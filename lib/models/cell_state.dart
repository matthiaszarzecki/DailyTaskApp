import 'package:daily_task_app/models/daily_task.dart';

class CellState {
  CellState({
    this.task,
    this.cellIsOpen,
  });

  DailyTask task;
  bool cellIsOpen;
}
