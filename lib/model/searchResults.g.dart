// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchResults.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorCard _$AuthorCardFromJson(Map<String, dynamic> json) {
  return AuthorCard(
    id: json['id'] as int,
    name: json['name'] as String,
    booksCount: json['booksCount'] as String,
  );
}

Map<String, dynamic> _$AuthorCardToJson(AuthorCard instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('booksCount', instance.booksCount);
  return val;
}

SequenceCard _$SequenceCardFromJson(Map<String, dynamic> json) {
  return SequenceCard(
    id: json['id'] as int,
    title: json['title'] as String,
    booksCount: json['booksCount'] as String,
  );
}

Map<String, dynamic> _$SequenceCardToJson(SequenceCard instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('title', instance.title);
  writeNotNull('booksCount', instance.booksCount);
  return val;
}
