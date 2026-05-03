// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually written Hive TypeAdapters for progress models

part of 'progress_model.dart';

// ─── WatchProgress Adapter ────────────────────────────────────────────────────

class WatchProgressAdapter extends TypeAdapter<WatchProgress> {
  @override
  final int typeId = 40;

  @override
  WatchProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchProgress(
      imdbId: fields[0] as String,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      backdropUrl: fields[3] as String? ?? '',
      lastPositionSeconds: fields[4] as int,
      totalDurationSeconds: fields[5] as int? ?? 0,
      lastWatchedDate: fields[6] as DateTime,
      type: fields[7] as String,
      tmdbId: fields[8] as String,
      rating: fields[9] as double? ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, WatchProgress obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.imdbId)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.posterUrl)
      ..writeByte(3)..write(obj.backdropUrl)
      ..writeByte(4)..write(obj.lastPositionSeconds)
      ..writeByte(5)..write(obj.totalDurationSeconds)
      ..writeByte(6)..write(obj.lastWatchedDate)
      ..writeByte(7)..write(obj.type)
      ..writeByte(8)..write(obj.tmdbId)
      ..writeByte(9)..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProgressAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// ─── FavoriteItem Adapter ─────────────────────────────────────────────────────

class FavoriteItemAdapter extends TypeAdapter<FavoriteItem> {
  @override
  final int typeId = 41;

  @override
  FavoriteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteItem(
      imdbId: fields[0] as String,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      type: fields[3] as String,
      rating: fields[4] as double? ?? 0.0,
      year: fields[5] as String? ?? '',
      genres: (fields[6] as List?)?.cast<String>() ?? [],
      addedDate: fields[7] as DateTime,
      tmdbId: fields[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.imdbId)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.posterUrl)
      ..writeByte(3)..write(obj.type)
      ..writeByte(4)..write(obj.rating)
      ..writeByte(5)..write(obj.year)
      ..writeByte(6)..write(obj.genres)
      ..writeByte(7)..write(obj.addedDate)
      ..writeByte(8)..write(obj.tmdbId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// ─── HistoryItem Adapter ──────────────────────────────────────────────────────

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 42;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      imdbId: fields[0] as String,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      watchedDate: fields[3] as DateTime,
      type: fields[4] as String,
      season: fields[5] as int?,
      episode: fields[6] as int?,
      tmdbId: fields[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.imdbId)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.posterUrl)
      ..writeByte(3)..write(obj.watchedDate)
      ..writeByte(4)..write(obj.type)
      ..writeByte(5)..write(obj.season)
      ..writeByte(6)..write(obj.episode)
      ..writeByte(7)..write(obj.tmdbId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// ─── SeriesProgress Adapter ───────────────────────────────────────────────────

class SeriesProgressAdapter extends TypeAdapter<SeriesProgress> {
  @override
  final int typeId = 43;

  @override
  SeriesProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesProgress(
      imdbId: fields[0] as String,
      lastSeason: fields[1] as int? ?? 1,
      lastEpisode: fields[2] as int? ?? 1,
      lastPositionSeconds: fields[3] as int? ?? 0,
      episodesWatched: (fields[4] as List?)?.cast<String>() ?? [],
      totalEpisodes: fields[5] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SeriesProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.imdbId)
      ..writeByte(1)..write(obj.lastSeason)
      ..writeByte(2)..write(obj.lastEpisode)
      ..writeByte(3)..write(obj.lastPositionSeconds)
      ..writeByte(4)..write(obj.episodesWatched)
      ..writeByte(5)..write(obj.totalEpisodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesProgressAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// ─── AppSettings Adapter ──────────────────────────────────────────────────────

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 44;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      language: fields[0] as String? ?? 'fr',
      subtitleLanguage: fields[1] as String? ?? 'ar',
      autoPlay: fields[2] as bool? ?? true,
      saveHistory: fields[3] as bool? ?? true,
      defaultStreamSource: fields[4] as String? ?? 'vidsrc',
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.language)
      ..writeByte(1)..write(obj.subtitleLanguage)
      ..writeByte(2)..write(obj.autoPlay)
      ..writeByte(3)..write(obj.saveHistory)
      ..writeByte(4)..write(obj.defaultStreamSource);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
