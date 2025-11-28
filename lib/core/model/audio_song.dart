import 'lyric_line.dart';

class AudioSong {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final String folderName;
  final String duration;
  final DateTime addedDate;
  final List<LyricLine>? lyrics;

  AudioSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.folderName,
    required this.duration,
    required this.addedDate,
    this.lyrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'folderName': folderName,
      'duration': duration,
      'addedDate': addedDate.toIso8601String(),
      'lyrics': lyrics?.map((line) => line.toJson()).toList(),
    };
  }

  factory AudioSong.fromJson(Map<String, dynamic> json) {
    return AudioSong(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      filePath: json['filePath'],
      folderName: json['folderName'],
      duration: json['duration'],
      addedDate: DateTime.parse(json['addedDate']),
      lyrics: json['lyrics'] != null
          ? (json['lyrics'] as List).map((line) => LyricLine.fromJson(line)).toList()
          : null,
    );
  }
}
