import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';

import 'package:daily_task_app/daily_task.dart';
import 'package:daily_task_app/data_store.dart';
import 'package:daily_task_app/task_screen.dart';

class IconPopupMenu {

  void openIconMenu(List<String> iconStrings, GlobalKey menuKey) {
    List<MenuItem> items = iconStrings.map(
      (String currentIconString) {
        return MenuItem(
          title: currentIconString,
          image: Icon(
            MdiIcons.fromString(currentIconString),
            color: Colors.white,
          ),
        );
      },
    ).toList();

    /*List<MenuItem> items = <vMenuItem>[
      MenuItem(
        title: 'Copy',
        image: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Home',
        textStyle: TextStyle(fontSize: 10.0, color: Colors.tealAccent),
        image: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Mail',
        image: Icon(
          Icons.mail,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Power',
        image: Icon(
          Icons.power,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'Setting',
        image: Icon(
          Icons.settings,
          color: Colors.white,
        ),
      ),
      MenuItem(
        title: 'PopupMenu',
        image: Icon(
          Icons.menu,
          color: Colors.white,
        ),
      )
    ];*/
    PopupMenu menu = PopupMenu(
      // backgroundColor: Colors.teal,
      // lineColor: Colors.white,
      // maxColumn: 2,
      items: items,
      onClickMenu: _iconItemClicked,
      stateChanged: _iconStateChanged,
      onDismiss: _iconMenuDismissed,
    );
    menu.show(widgetKey: menuKey);
  }

  void _iconStateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void _iconMenuDismissed() {
    print('Menu is dismissed');
  }

  void _iconItemClicked(MenuItemProvider item) {
    _setNewIconForTask(
      currentSelectedTask,
      currentSelectedIndex,
      item.menuTitle,
    );
  }

// TODO(MZ): Does this class need a state for setState to work?
  void _setNewIconForTask(DailyTask task, int index, String iconString) {
    setState(() {
      task.iconString = iconString;
    });
    DataStore.updateSingleTask(task, index);
    print('Updated Icon to ${task.iconString}');
  }
}
