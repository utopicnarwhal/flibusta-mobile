

import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final void Function(int) onTap;
  final int index;

  const HomeBottomNavBar({
    Key key,
    @required this.onTap,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: Key('HomeBottomNavBar'),
      currentIndex: index,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.view_list),
          title: Text('Последние книги'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Настройки'),
        ),
      ],
      onTap: onTap,
    );
  }
}