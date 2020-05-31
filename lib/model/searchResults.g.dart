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

Map<String, dynamic> _$AuthorCardToJson(AuthorCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'booksCount': instance.booksCount,
    };

SequenceCard _$SequenceCardFromJson(Map<String, dynamic> json) {
  return SequenceCard(
    id: json['id'] as int,
    title: json['title'] as String,
    booksCount: json['booksCount'] as String,
  );
}

Map<String, dynamic> _$SequenceCardToJson(SequenceCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'booksCount': instance.booksCount,
    };
