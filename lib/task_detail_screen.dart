import 'package:daily_task_app/daily_task.dart';
import 'package:flutter/material.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({Key key, this.task}) : super(key: key);

  final DailyTask task;

  @override
  _TaskDetailScreenState createState() {
    return _TaskDetailScreenState();
  }
}

// TODO(mz): Have new screen show details of task
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Center(
        child: Text(widget.task.title),
      ),
    );
  }
}
