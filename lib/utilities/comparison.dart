import 'package:daily_task_app/enums/task_status.dart';
import 'package:daily_task_app/models/cell_state.dart';

/// Compares CellState's by status. "Todo" are up top, followed by "done" and "failed".
int compareCellStates(CellState a, CellState b) {
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
