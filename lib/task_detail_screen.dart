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

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            widget.task.getIcon(Colors.red),
            Text('Counter: ${widget.task.counter}'),
            Text('Last Modified: ${widget.task.lastModified}'),
          ],
        ),
      ),
    );
  }
}
