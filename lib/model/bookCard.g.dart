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

Map<String, dynamic> _$BookCardToJson(BookCard instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('genres', instance.genres?.toJson());
  writeNotNull('sequenceId', instance.sequenceId);
  writeNotNull('sequenceTitle', instance.sequenceTitle);
  writeNotNull('title', instance.title);
  writeNotNull('size', instance.size);
  writeNotNull('downloadFormats', instance.downloadFormats?.toJson());
  writeNotNull('authors', instance.authors?.toJson());
  writeNotNull('translators', instance.translators?.toJson());
  writeNotNull('downloadProgress', instance.downloadProgress);
  writeNotNull('localPath', instance.localPath);
  return val;
}

DownloadFormats _$DownloadFormatsFromJson(Map<String, dynamic> json) {
  return DownloadFormats(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(k, e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$DownloadFormatsToJson(DownloadFormats instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('list', instance.list);
  return val;
}

Authors _$AuthorsFromJson(Map<String, dynamic> json) {
  return Authors(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$AuthorsToJson(Authors instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'list',
      instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList());
  return val;
}

Translators _$TranslatorsFromJson(Map<String, dynamic> json) {
  return Translators(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$TranslatorsToJson(Translators instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'list',
      instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList());
  return val;
}

Genres _$GenresFromJson(Map<String, dynamic> json) {
  return Genres(
    (json['list'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(int.parse(k), e as String),
            ))
        ?.toList(),
  );
}

Map<String, dynamic> _$GenresToJson(Genres instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'list',
      instance.list
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList());
  return val;
}
