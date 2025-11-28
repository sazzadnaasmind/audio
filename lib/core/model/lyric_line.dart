class LyricLine {
  final int timestamp; // in seconds
  final String english;
  final Map<String, String> translations;

  LyricLine({
    required this.timestamp,
    required this.english,
    required this.translations,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      timestamp: json['timestamp'] as int,
      english: json['english'] as String,
      translations: Map<String, String>.from(json['translations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'english': english,
      'translations': translations,
    };
  }

  String getTranslation(String language) {
    if (language == 'English') return english;
    return translations[language] ?? english;
  }
}

