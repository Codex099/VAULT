class ActorModel {
  final int id;
  final String name;
  final String? biography;
  final String? profilePath;
  final String? birthday;
  final String? placeOfBirth;
  final double popularity;
  final String? knownForDepartment;
  final List<ActorCredit> credits;

  const ActorModel({
    required this.id, required this.name, this.biography,
    this.profilePath, this.birthday, this.placeOfBirth,
    this.popularity = 0.0, this.knownForDepartment, this.credits = const [],
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    final combined = json['combined_credits'] as Map<String, dynamic>?;
    final cast = combined?['cast'] as List<dynamic>? ?? [];
    return ActorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      profilePath: json['profile_path'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      knownForDepartment: json['known_for_department'] as String?,
      credits: cast
          .take(20)
          .map((e) => ActorCredit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get fullProfileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w300$profilePath' : '';
}

class ActorCredit {
  final int id;
  final String title;
  final String? posterPath;
  final String? character;
  final String? mediaType;
  final String? releaseDate;
  final double voteAverage;

  const ActorCredit({
    required this.id, required this.title, this.posterPath,
    this.character, this.mediaType, this.releaseDate, this.voteAverage = 0.0,
  });

  factory ActorCredit.fromJson(Map<String, dynamic> json) => ActorCredit(
        id: json['id'] as int,
        title: (json['title'] ?? json['name'] ?? '') as String,
        posterPath: json['poster_path'] as String?,
        character: json['character'] as String?,
        mediaType: json['media_type'] as String?,
        releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      );

  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w300$posterPath' : '';
}
