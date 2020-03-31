import 'package:daily_task_app/daily_task.dart';

class CellState {
  CellState({
    this.task,
    this.open,
    this.todo,
  });

  DailyTask task;
  bool open;
  bool todo;
}
