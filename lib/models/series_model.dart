import 'movie_model.dart';

class SeriesModel {
  final int tmdbId;
  final String? imdbId;
  final String name;
  final String? originalName;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? firstAirDate;
  final List<int> genreIds;
  final String? originalLanguage;
  final double popularity;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<SeasonSummary> seasons;
  final List<GenreModel> genres;
  final List<CastMember> cast;
  final List<VideoResult> videos;
  final List<SeriesModel> similar;
  final List<SeriesModel> recommendations;
  final String? status;
  final String? tagline;
  final List<int>? episodeRunTime;

  const SeriesModel({
    required this.tmdbId,
    this.imdbId,
    required this.name,
    this.originalName,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.firstAirDate,
    this.genreIds = const [],
    this.originalLanguage,
    this.popularity = 0.0,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.seasons = const [],
    this.genres = const [],
    this.cast = const [],
    this.videos = const [],
    this.similar = const [],
    this.recommendations = const [],
    this.status,
    this.tagline,
    this.episodeRunTime,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      tmdbId: json['id'] as int? ?? 0,
      imdbId: json['imdb_id'] as String?,
      name: (json['name'] ?? json['title'] ?? '') as String,
      originalName: (json['original_name'] ?? json['original_title']) as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      firstAirDate: (json['first_air_date'] ?? json['release_date']) as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      originalLanguage: json['original_language'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => SeasonSummary.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      cast: _parseCast(json),
      videos: _parseVideos(json),
      similar: _parseSimilar(json),
      recommendations: _parseRecs(json),
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
      episodeRunTime: (json['episode_run_time'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  static List<CastMember> _parseCast(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>?;
    return (credits?['cast'] as List<dynamic>?)
        ?.take(20)
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  static List<VideoResult> _parseVideos(Map<String, dynamic> json) {
    final videos = json['videos'] as Map<String, dynamic>?;
    return (videos?['results'] as List<dynamic>?)
        ?.map((e) => VideoResult.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  static List<SeriesModel> _parseSimilar(Map<String, dynamic> json) {
    final s = json['similar'] as Map<String, dynamic>?;
    return (s?['results'] as List<dynamic>?)
        ?.take(10)
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  static List<SeriesModel> _parseRecs(Map<String, dynamic> json) {
    final r = json['recommendations'] as Map<String, dynamic>?;
    return (r?['results'] as List<dynamic>?)
        ?.take(10)
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  String get year =>
      firstAirDate != null && firstAirDate!.isNotEmpty ? firstAirDate!.substring(0, 4) : '';

  String get runtimeFormatted {
    final rt = episodeRunTime?.isNotEmpty == true ? episodeRunTime!.first : 0;
    return rt == 0 ? '' : '${rt}min/ep';
  }

  VideoResult? get trailer {
    try {
      return videos.firstWhere((v) => v.type == 'Trailer' && v.site == 'YouTube');
    } catch (_) {
      return videos.isNotEmpty ? videos.first : null;
    }
  }

  SeriesModel copyWith({String? imdbId}) {
    return SeriesModel(
      tmdbId: tmdbId, imdbId: imdbId ?? this.imdbId, name: name,
      originalName: originalName, overview: overview, posterPath: posterPath,
      backdropPath: backdropPath, voteAverage: voteAverage, voteCount: voteCount,
      firstAirDate: firstAirDate, genreIds: genreIds, originalLanguage: originalLanguage,
      popularity: popularity, numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes, seasons: seasons, genres: genres,
      cast: cast, videos: videos, similar: similar, recommendations: recommendations,
      status: status, tagline: tagline, episodeRunTime: episodeRunTime,
    );
  }
}

class SeasonSummary {
  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String? posterPath;
  final String? overview;
  final String? airDate;

  const SeasonSummary({
    required this.id, required this.name, required this.seasonNumber,
    this.episodeCount = 0, this.posterPath, this.overview, this.airDate,
  });

  factory SeasonSummary.fromJson(Map<String, dynamic> json) => SeasonSummary(
        id: json['id'] as int,
        name: json['name'] as String,
        seasonNumber: json['season_number'] as int,
        episodeCount: json['episode_count'] as int? ?? 0,
        posterPath: json['poster_path'] as String?,
        overview: json['overview'] as String?,
        airDate: json['air_date'] as String?,
      );

  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w300$posterPath' : '';
}
