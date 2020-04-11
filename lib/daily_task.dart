import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:daily_task_app/date_time_parser.dart';
import 'package:daily_task_app/task_screen.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.iconString,
    this.lastModified,
    this.interval,
    this.status,
    this.currentStreak,
    this.longestStreak,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        iconString = json['iconString'],
        lastModified = dateFromString(json['lastModified']),
        interval = json['interval'],
        status = EnumToString.fromString(TaskStatus.values, json['status']),
        currentStreak = json['currentStreak'],
        longestStreak = json['longestStreak'];

  String title;
  String iconString;
  DateTime lastModified;
  String interval;
  TaskStatus status;
  int currentStreak;
  int longestStreak;

  IconData getIconData() {
    return MdiIcons.fromString(iconString) ?? Icons.hourglass_full;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'iconString': iconString,
      'lastModified': DateTime.now().toIso8601String(),
      'interval': interval,
      'status': EnumToString.parse(status),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  @override
  String toString() {
    return 'DailyTask: $title, icon: $iconString, lastModifed: $lastModified, interval: $interval, status: $status, currentStreak: $currentStreak, longestStreak: $longestStreak';
  }
}
