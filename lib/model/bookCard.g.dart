// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookCard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookCard _$BookCardFromJson(Map<String, dynamic> json) {
  return BookCard(
    id: json['id'] as int,
    genres: json['genres'] == null
        ? null
        : Genres.fromJson(json['genres'] as Map<String, dynamic>),
    sequenceId: json['sequenceId'] as int,
    sequenceTitle: json['sequenceTitle'] as String,
    title: json['title'] as String,
    size: json['size'] as String,
    downloadFormats: json['downloadFormats'] == null
        ? null
        : DownloadFormats.fromJson(
            json['downloadFormats'] as Map<String, dynamic>),
    authors: json['authors'] == null
        ? null
        : Authors.fromJson(json['authors'] as Map<String, dynamic>),
    translators: json['translators'] == null
        ? null
        : Translators.fromJson(json['translators'] as Map<String, dynamic>),
    localPath: json['localPath'] as String,
  )..downloadProgress = (json['downloadProgress'] as num)?.toDouble();
}

Map<String, dynamic> _$BookCardToJson(BookCard instance) => <String, dynamic>{
      'id': instance.id,
      'genres': instance.genres?.toJson(),
      'sequenceId': instance.sequenceId,
      'sequenceTitle': instance.sequenceTitle,
      'title': instance.title,
      'size': instance.size,
      'downloadFormats': instance.downloadFormats?.toJson(),
      'authors': instance.authors?.toJson(),
      'translators': instance.translators?.toJson(),
      'downloadProgress': instance.downloadProgress,
      'localPath': instance.localPath,
    };

DownloadFormats _$DownloadFormatsFromJson(Map<String, dynamic> json) {
  return DownloadFormats(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(k, e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$DownloadFormatsToJson(DownloadFormats instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

Authors _$AuthorsFromJson(Map<String, dynamic> json) {
  return Authors(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$AuthorsToJson(Authors instance) => <String, dynamic>{
      'list': instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
    };

Translators _$TranslatorsFromJson(Map<String, dynamic> json) {
  return Translators(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$TranslatorsToJson(Translators instance) =>
    <String, dynamic>{
      'list': instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
    };

Genres _$GenresFromJson(Map<String, dynamic> json) {
  return Genres(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$GenresToJson(Genres instance) => <String, dynamic>{
      'list': instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
    };
