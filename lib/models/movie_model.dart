class MovieModel {
  final int tmdbId;
  final String? imdbId;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool adult;
  final String? originalLanguage;
  final double popularity;
  final bool video;
  final int? runtime;
  final String? tagline;
  final String? status;
  final List<GenreModel> genres;
  final List<CastMember> cast;
  final List<VideoResult> videos;
  final List<MovieModel> similar;
  final List<MovieModel> recommendations;
  final String? mediaType;

  const MovieModel({
    required this.tmdbId,
    this.imdbId,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
    this.adult = false,
    this.originalLanguage,
    this.popularity = 0.0,
    this.video = false,
    this.runtime,
    this.tagline,
    this.status,
    this.genres = const [],
    this.cast = const [],
    this.videos = const [],
    this.similar = const [],
    this.recommendations = const [],
    this.mediaType,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      tmdbId: json['id'] as int? ?? 0,
      imdbId: json['imdb_id'] as String?,
      title: (json['title'] ?? json['name'] ?? '') as String,
      originalTitle: (json['original_title'] ?? json['original_name']) as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      adult: json['adult'] as bool? ?? false,
      originalLanguage: json['original_language'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      video: json['video'] as bool? ?? false,
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      cast: _parseCast(json),
      videos: _parseVideos(json),
      similar: _parseMovieList(json, 'similar'),
      recommendations: _parseMovieList(json, 'recommendations'),
      mediaType: json['media_type'] as String?,
    );
  }

  static List<CastMember> _parseCast(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>?;
    if (credits == null) return [];
    return (credits['cast'] as List<dynamic>?)
        ?.take(20)
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  static List<VideoResult> _parseVideos(Map<String, dynamic> json) {
    final videos = json['videos'] as Map<String, dynamic>?;
    if (videos == null) return [];
    return (videos['results'] as List<dynamic>?)
        ?.map((e) => VideoResult.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  static List<MovieModel> _parseMovieList(Map<String, dynamic> json, String key) {
    final section = json[key] as Map<String, dynamic>?;
    if (section == null) return [];
    return (section['results'] as List<dynamic>?)
        ?.take(10)
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  String get year =>
      releaseDate != null && releaseDate!.isNotEmpty ? releaseDate!.substring(0, 4) : '';

  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h == 0 ? '${m}min' : '${h}h ${m}min';
  }

  VideoResult? get trailer {
    try {
      return videos.firstWhere((v) => v.type == 'Trailer' && v.site == 'YouTube');
    } catch (_) {
      return videos.isNotEmpty ? videos.first : null;
    }
  }

  MovieModel copyWith({String? imdbId}) {
    return MovieModel(
      tmdbId: tmdbId, imdbId: imdbId ?? this.imdbId, title: title,
      originalTitle: originalTitle, overview: overview, posterPath: posterPath,
      backdropPath: backdropPath, voteAverage: voteAverage, voteCount: voteCount,
      releaseDate: releaseDate, genreIds: genreIds, adult: adult,
      originalLanguage: originalLanguage, popularity: popularity, video: video,
      runtime: runtime, tagline: tagline, status: status, genres: genres,
      cast: cast, videos: videos, similar: similar, recommendations: recommendations,
      mediaType: mediaType,
    );
  }
}

class GenreModel {
  final int id;
  final String name;
  const GenreModel({required this.id, required this.name});
  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      GenreModel(id: json['id'] as int, name: json['name'] as String);
}

class CastMember {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int? order;

  const CastMember({required this.id, required this.name, this.character, this.profilePath, this.order});

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int,
        name: json['name'] as String,
        character: json['character'] as String?,
        profilePath: json['profile_path'] as String?,
        order: json['order'] as int?,
      );

  String get fullProfileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';
}

class VideoResult {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;

  const VideoResult({required this.id, required this.name, required this.key, required this.site, required this.type});

  factory VideoResult.fromJson(Map<String, dynamic> json) => VideoResult(
        id: json['id'] as String,
        name: json['name'] as String,
        key: json['key'] as String,
        site: json['site'] as String,
        type: json['type'] as String,
      );

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
}
