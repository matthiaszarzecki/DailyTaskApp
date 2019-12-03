import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.counter,
    this.iconString,
    this.lastModified,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        counter = json['counter'],
        iconString = json['iconString'],
        lastModified = _dateFromString(json['lastModified']);

  final String title;
  final int counter;
  final String iconString;
  final DateTime lastModified;

  Icon getIcon() {
    return Icon(MdiIcons.fromString(iconString));
  }

  static DateTime _dateFromString(String key) {
    return DateTime.parse(key);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'counter': counter,
      'icon': iconString,
      'lastModified': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DailyTask: $title, $counter, Icon: $iconString, lastModifed: $lastModified';
  }
}
