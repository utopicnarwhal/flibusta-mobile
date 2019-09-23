import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          icon: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Icon(
              FontAwesomeIcons.projectDiagram,
              size: 18,
            ),
          ),
          title: Text('Прокси'),
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
