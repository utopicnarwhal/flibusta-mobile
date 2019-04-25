
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData gridRowNameToIcon(String rowName) {
  switch (rowName) {
    case 'Название произведения':
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
    default:
      return FontAwesomeIcons.question;
  }
}