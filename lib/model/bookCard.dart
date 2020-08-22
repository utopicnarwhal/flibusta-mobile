import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bookCard.g.dart';

@JsonSerializable()
class BookCard extends GridData {
  int id;
  Genres genres;
  int sequenceId;
  String sequenceTitle;
  String title;
  String size;

  @JsonKey(ignore: true)
  String addedToLibraryDate;

  @JsonKey(ignore: true)
  int fileScore;

  DownloadFormats downloadFormats;
  Authors authors;
  Translators translators;
  double downloadProgress;
  String localPath;

  String get tileTitle {
    return title;
  }

  String get tileSubtitle {
    return authors?.toString();
  }

  BookCard({
    this.id,
    this.genres,
    this.sequenceId,
    this.sequenceTitle,
    this.title,
    this.size,
    this.downloadFormats,
    this.addedToLibraryDate,
    this.authors,
    this.translators,
    this.localPath,
    this.fileScore,
  }) : assert(id != null);

  factory BookCard.fromJson(Map<String, dynamic> json) =>
      _$BookCardFromJson(json);
  Map<String, dynamic> toJson() => _$BookCardToJson(this);
}

String fileScoreToString(int fileScore) {
  if (fileScore == null) return null;

  switch (fileScore) {
    case 1:
      return 'Файл на 1';
    case 2:
      return 'Файл на 2';
    case 3:
      return 'Файл на 3';
    case 4:
      return 'Файл на 4';
    case 5:
      return 'Файл на 5';
    default:
      return 'Файл не оценен';
  }
}

@JsonSerializable()
class DownloadFormats {
  DownloadFormats(this.list);

  List<Map<String, String>> list;

  bool get isNotEmpty {
    return list != null ? list.isNotEmpty : false;
  }

  bool get isEmpty {
    return list != null ? list.isEmpty : true;
  }

  @override
  String toString() {
    if (list == null || list.isEmpty) {
      return "";
    }
    var result = "";
    list.forEach((f) {
      result += f.keys.first;
      if (f != list.last) {
        result += ", ";
      }
    });
    return result;
  }

  static IconData getIconDataForFormat(String format) {
    switch (format) {
      case "скачать docx":
      case "docx":
        return FontAwesomeIcons.solidFileWord;
      case "fb2":
        return FontAwesomeIcons.bookReader;
      case "epub":
        return FontAwesomeIcons.leanpub;
      case "скачать pdf":
      case "pdf":
        return FontAwesomeIcons.solidFilePdf;
      default:
        return FontAwesomeIcons.book;
    }
  }

  factory DownloadFormats.fromJson(Map<String, dynamic> json) =>
      _$DownloadFormatsFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadFormatsToJson(this);
}

@JsonSerializable()
class Authors {
  Authors(this.list);

  List<Map<int, String>> list;

  bool get isNotEmpty {
    return list != null ? list.isNotEmpty : false;
  }

  bool get isEmpty {
    return list != null ? list.isEmpty : true;
  }

  @override
  String toString() {
    if (list == null || list.isEmpty) {
      return '';
    }
    var result = '';
    list.forEach((f) {
      result += f.values.first;
      if (f != list.last) {
        result += ", ";
      }
    });
    return result;
  }

  factory Authors.fromJson(Map<String, dynamic> json) =>
      _$AuthorsFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorsToJson(this);
}

@JsonSerializable()
class Translators {
  Translators(this.list);

  List<Map<int, String>> list;

  bool get isNotEmpty {
    return list != null ? list.isNotEmpty : false;
  }

  bool get isEmpty {
    return list != null ? list.isEmpty : true;
  }

  @override
  String toString() {
    if (list == null || list.isEmpty) {
      return '';
    }
    var result = "";
    list.forEach((f) {
      result += f.values.first;
      if (f != list.last) {
        result += ", ";
      }
    });
    return result;
  }

  factory Translators.fromJson(Map<String, dynamic> json) =>
      _$TranslatorsFromJson(json);
  Map<String, dynamic> toJson() => _$TranslatorsToJson(this);
}

@JsonSerializable()
class Genres {
  Genres(this.list);

  List<Map<int, String>> list;

  bool get isNotEmpty {
    return list != null ? list.isNotEmpty : false;
  }

  bool get isEmpty {
    return list != null ? list.isEmpty : true;
  }

  @override
  String toString() {
    if (list == null || list.isEmpty) {
      return '';
    }
    var result = "";
    list.forEach((f) {
      result += f.values.first;
      if (f != list.last) {
        result += ", ";
      }
    });
    return result.replaceAll(RegExp(r'(\[|\])'), "");
  }

  factory Genres.fromJson(Map<String, dynamic> json) => _$GenresFromJson(json);
  Map<String, dynamic> toJson() => _$GenresToJson(this);
}
