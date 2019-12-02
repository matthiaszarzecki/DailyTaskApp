import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.counter,
    this.icon,
    this.lastModified,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        counter = json['counter'],
        icon = Icon(MdiIcons.sword),//_iconFromKey(json['icon']),
        lastModified = DateTime.now();//_dateFromString(json['lastModified']);

  final String title;
  final int counter;
  final Icon icon;
  final DateTime lastModified;

  static Icon _iconFromKey(String key) {
    return Icon(MdiIcons.fromString(key));
  }

  static DateTime _dateFromString(String key) {
    return DateTime.parse(key);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'counter': counter,
      'icon': icon.toString(),
      'lastModified': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    String info = 'DailyTask: $title, $counter, Icon: $icon';
    return info;
  }
}
