import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData gridRowNameToIcon(String rowName) {
  switch (rowName) {
    case 'Название произведения':
    case 'Имя автора':
    case 'Название серии':
      return Icons.title;
    case 'Автор(-ы)':
      return Icons.assignment_ind;
    case 'Перевод':
      return Icons.translate;
    case 'Жанр произведения':
      return FontAwesomeIcons.americanSignLanguageInterpreting;
    case 'Из серии произведений':
      return Icons.collections_bookmark;
    case 'Размер книги':
      return Icons.data_usage;
    case 'Форматы файлов':
      return Icons.file_download;
    case 'Путь к файлу':
      return FontAwesomeIcons.folder;
    case 'Количество книг':
    case 'Количество книг в серии':
      return Icons.confirmation_number;
    default:
      return FontAwesomeIcons.question;
  }
}

Icon scoreToIcon(int score, double size) {
  IconData iconData;
  Color color;
  switch (score) {
    case 0:
      iconData = FontAwesomeIcons.star;
      color = Colors.grey;
      break;
    case 1:
      iconData = FontAwesomeIcons.poop;
      color = Colors.brown;
      break;
    case 2:
      iconData = FontAwesomeIcons.solidFrown;
      color = Colors.grey;
      break;
    case 3:
      iconData = FontAwesomeIcons.solidMeh;
      color = Colors.blue;
      break;
    case 4:
      iconData = FontAwesomeIcons.solidSmile;
      color = Colors.green;
      break;
    case 5:
      iconData = FontAwesomeIcons.solidStar;
      color = Colors.yellow;
      break;
    default:
      iconData = FontAwesomeIcons.question;
      color = Colors.black;
  }
  return Icon(
    iconData,
    size: size,
    color: color,
  );
}
