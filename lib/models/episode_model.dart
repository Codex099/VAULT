class EpisodeModel {
  final int id;
  final String name;
  final int episodeNumber;
  final int seasonNumber;
  final String? overview;
  final String? stillPath;
  final double voteAverage;
  final String? airDate;
  final int? runtime;

  const EpisodeModel({
    required this.id, required this.name,
    required this.episodeNumber, required this.seasonNumber,
    this.overview, this.stillPath, this.voteAverage = 0.0,
    this.airDate, this.runtime,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        episodeNumber: json['episode_number'] as int,
        seasonNumber: json['season_number'] as int,
        overview: json['overview'] as String?,
        stillPath: json['still_path'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        airDate: json['air_date'] as String?,
        runtime: json['runtime'] as int?,
      );

  String get fullStillUrl =>
      stillPath != null ? 'https://image.tmdb.org/t/p/w300$stillPath' : '';

  String get code =>
      'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';

  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h == 0 ? '${m}min' : '${h}h ${m}min';
  }
}

class SeasonDetail {
  final int id;
  final String name;
  final int seasonNumber;
  final List<EpisodeModel> episodes;
  final String? posterPath;
  final String? overview;

  const SeasonDetail({
    required this.id, required this.name, required this.seasonNumber,
    this.episodes = const [], this.posterPath, this.overview,
  });

  factory SeasonDetail.fromJson(Map<String, dynamic> json) => SeasonDetail(
        id: json['id'] as int,
        name: json['name'] as String,
        seasonNumber: json['season_number'] as int,
        episodes: (json['episodes'] as List<dynamic>?)
                ?.map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
                .toList() ?? [],
        posterPath: json['poster_path'] as String?,
        overview: json['overview'] as String?,
      );
}
