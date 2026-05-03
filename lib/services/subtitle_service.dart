import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class SubtitleResult {
  final String id;
  final String language;
  final String fileName;
  final String downloadUrl;
  final int downloadCount;

  const SubtitleResult({
    required this.id,
    required this.language,
    required this.fileName,
    required this.downloadUrl,
    this.downloadCount = 0,
  });

  factory SubtitleResult.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] as Map<String, dynamic>? ?? {};
    final files = attrs['files'] as List<dynamic>? ?? [];
    final fileData =
        files.isNotEmpty ? files.first as Map<String, dynamic> : {};
    return SubtitleResult(
      id: json['id'] as String? ?? '',
      language: attrs['language'] as String? ?? '',
      fileName: fileData['file_name'] as String? ?? '',
      downloadUrl: '',
      downloadCount: attrs['download_count'] as int? ?? 0,
    );
  }
}

class SubtitleService {
  static final _headers = {
    'Api-Key': AppConfig.openSubsApiKey,
    'Content-Type': 'application/json',
    'User-Agent': 'CineStream v1.0',
  };

  static Future<List<SubtitleResult>> searchSubtitles(
    String imdbId, {
    String language = 'ar',
  }) async {
    if (AppConfig.openSubsApiKey == 'YOUR_OPENSUBTITLES_API_KEY_HERE') {
      return [];
    }

    try {
      final uri = Uri.parse('${AppConfig.openSubsBaseUrl}/subtitles').replace(
        queryParameters: {
          'imdb_id': imdbId.replaceFirst('tt', ''),
          'languages': language,
          'order_by': 'download_count',
          'order_direction': 'desc',
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['data'] as List<dynamic>? ?? [];
        return results
            .map((e) => SubtitleResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Subtitle fetch failure is non-critical
    }
    return [];
  }

  static Future<String?> getDownloadUrl(String fileId) async {
    if (AppConfig.openSubsApiKey == 'YOUR_OPENSUBTITLES_API_KEY_HERE') {
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.openSubsBaseUrl}/download'),
            headers: _headers,
            body: jsonEncode({'file_id': fileId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['link'] as String?;
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  static Future<String?> downloadSubtitleContent(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }
}
