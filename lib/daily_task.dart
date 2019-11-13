import 'package:flutter/material.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.counter,
    this.icon,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        counter = json['counter'],
        icon = json['icon'];

  String title;
  int counter;
  Icon icon;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'counter': counter,
      'icon': icon,
    };
  }
}
