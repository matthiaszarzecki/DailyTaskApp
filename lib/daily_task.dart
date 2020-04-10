import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.iconString,
    this.lastModified,
    this.interval,
    this.markedAsDone,
    this.currentStreak,
    this.longestStreak,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        iconString = json['iconString'],
        lastModified = _dateFromString(json['lastModified']),
        interval = json['interval'],
        markedAsDone = json['markedAsDone'],
        currentStreak = json['currentStreak'],
        longestStreak = json['longestStreak'];

  String title;
  String iconString;
  DateTime lastModified;
  String interval;
  bool markedAsDone;
  int currentStreak;
  int longestStreak;

  IconData getIconData() {
    return MdiIcons.fromString(iconString) ?? Icons.hourglass_full;
  }

  // TODO(MZ): Used twice - move to single location
  static DateTime _dateFromString(String key) {
    return DateTime.parse(key);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'iconString': iconString,
      'lastModified': DateTime.now().toIso8601String(),
      'interval': interval,
      'markedAsDone': markedAsDone,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  @override
  String toString() {
    return 'DailyTask: $title, icon: $iconString, lastModifed: $lastModified, interval: $interval, markedAsDone: $markedAsDone, currentStreak: $currentStreak, longestStreak: $longestStreak';
  }
}
