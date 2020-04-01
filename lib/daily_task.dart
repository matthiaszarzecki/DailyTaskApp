import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DailyTask {
  DailyTask({
    this.title,
    this.counter,
    this.iconString,
    this.lastModified,
    this.interval,
  });

  DailyTask.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        counter = json['counter'],
        iconString = json['iconString'],
        lastModified = _dateFromString(json['lastModified']),
        interval = json['interval'];

  String title;
  final int counter;
  String iconString;
  DateTime lastModified;
  String interval;

  Icon getIcon() {
    return Icon(MdiIcons.fromString(iconString)) ?? Icon(Icons.hourglass_full);
  }

  static DateTime _dateFromString(String key) {
    return DateTime.parse(key);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'counter': counter,
      'iconString': iconString,
      'lastModified': DateTime.now().toIso8601String(),
      'interval': interval,
    };
  }

  @override
  String toString() {
    return 'DailyTask: $title, $counter, icon: $iconString, lastModifed: $lastModified, interval: $interval';
  }
}
