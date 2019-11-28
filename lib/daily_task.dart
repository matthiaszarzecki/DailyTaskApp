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
        icon = _iconFromKey(json['icon']);

  final String title;
  final int counter;
  final Icon icon;

  static Icon _iconFromKey(String key) {
    return Icon(Icons.hot_tub);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'counter': counter,
      'icon': 'icon',
    };
  }

  @override
  String toString() {
    String info = 'DailyTask: $title, $counter, Icon: $icon';
    return info;
  }
}
