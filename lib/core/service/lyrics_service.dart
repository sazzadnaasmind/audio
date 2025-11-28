import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/lyric_line.dart';
import '../model/audio_song.dart';

class LyricsService {
  // Fetch lyrics - first try local file, then online API
  static Future<List<LyricLine>?> fetchLyrics(AudioSong song) async {
    try {
      // First, try to find local .lrc file
      final localLyrics = await _loadLocalLyrics(song.filePath);
      if (localLyrics != null && localLyrics.isNotEmpty) {
        print('Loaded lyrics from local file');
        return localLyrics;
      }

      // If no local lyrics, try online APIs
      print('No local lyrics found, fetching from online...');
      return await _fetchFromOnline(song);
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
    }
  }

  // Load lyrics from local .lrc file
  static Future<List<LyricLine>?> _loadLocalLyrics(String audioFilePath) async {
    try {
      // Get the directory and filename without extension
      final audioFile = File(audioFilePath);
      final directory = audioFile.parent.path;
      final fileNameWithoutExt = audioFile.path.split('/').last.split('\\').last.replaceAll(RegExp(r'\.(mp3|m4a|wav|aac|opus|flac)$', caseSensitive: false), '');

      // Look for .lrc file with same name
      final lrcPath = '$directory/$fileNameWithoutExt.lrc';
      final lrcFile = File(lrcPath);

      if (await lrcFile.exists()) {
        print('Found local LRC file: $lrcPath');
        final content = await lrcFile.readAsString();
        return _parseLrcFile(content);
      }

      return null;
    } catch (e) {
      print('Error loading local lyrics: $e');
      return null;
    }
  }

  // Parse LRC file format
  static List<LyricLine> _parseLrcFile(String lrcContent) {
    List<LyricLine> lyrics = [];
    final lines = lrcContent.split('\n');

    for (String line in lines) {
      // Match LRC format: [MM:SS.XX] or [MM:SS]
      final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2}))?\](.*)');
      final match = regex.firstMatch(line);

      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final text = match.group(4)!.trim();

        if (text.isNotEmpty) {
          lyrics.add(LyricLine(
            timestamp: (minutes * 60) + seconds,
            english: text,
            translations: {},
          ));
        }
      }
    }

    // Sort by timestamp
    lyrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return lyrics;
  }

  // Fetch lyrics from online API
  static Future<List<LyricLine>?> _fetchFromOnline(AudioSong song) async {
    try {
      String cleanTitle = song.title.trim();
      String cleanArtist = song.artist.trim();

      // Try lrclib.net API
      final url = Uri.parse(
        'https://lrclib.net/api/get?artist_name=${Uri.encodeComponent(cleanArtist)}&track_name=${Uri.encodeComponent(cleanTitle)}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['syncedLyrics'] != null && data['syncedLyrics'].isNotEmpty) {
          return _parseSyncedLyrics(data['syncedLyrics']);
        } else if (data['plainLyrics'] != null && data['plainLyrics'].isNotEmpty) {
          return _parsePlainLyrics(data['plainLyrics']);
        }
      }

      // If lrclib fails, try alternative API
      return await _fetchFromAlternativeSource(cleanTitle, cleanArtist);
    } catch (e) {
      print('Error fetching from online: $e');
      return null;
    }
  }

  // Parse synced lyrics (LRC format with timestamps)
  static List<LyricLine> _parseSyncedLyrics(String syncedLyrics) {
    return _parseLrcFile(syncedLyrics);
  }

  // Parse plain lyrics (no timestamps)
  static List<LyricLine> _parsePlainLyrics(String plainLyrics) {
    List<LyricLine> lyrics = [];
    final lines = plainLyrics.split('\n');

    // Estimate timestamps (4 seconds per line)
    int currentTime = 0;

    for (String line in lines) {
      final text = line.trim();
      if (text.isNotEmpty && !text.startsWith('[')) {
        lyrics.add(LyricLine(
          timestamp: currentTime,
          english: text,
          translations: {},
        ));
        currentTime += 4; // 4 seconds per line estimate
      }
    }

    return lyrics;
  }

  // Alternative source (lyrics.ovh - free API)
  static Future<List<LyricLine>?> _fetchFromAlternativeSource(String title, String artist) async {
    try {
      final url = Uri.parse(
        'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['lyrics'] != null && data['lyrics'].isNotEmpty) {
          return _parsePlainLyrics(data['lyrics']);
        }
      }
    } catch (e) {
      print('Error fetching from alternative source: $e');
    }

    return null;
  }

  // Save lyrics to local .lrc file
  static Future<bool> saveLyricsToFile(String audioFilePath, List<LyricLine> lyrics) async {
    try {
      final audioFile = File(audioFilePath);
      final directory = audioFile.parent.path;
      final fileNameWithoutExt = audioFile.path.split('/').last.split('\\').last.replaceAll(RegExp(r'\.(mp3|m4a|wav|aac|opus|flac)$', caseSensitive: false), '');

      final lrcPath = '$directory/$fileNameWithoutExt.lrc';
      final lrcFile = File(lrcPath);

      // Convert lyrics to LRC format
      final lrcContent = StringBuffer();
      for (var lyric in lyrics) {
        final minutes = lyric.timestamp ~/ 60;
        final seconds = lyric.timestamp % 60;
        lrcContent.writeln('[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}]${lyric.english}');
      }

      await lrcFile.writeAsString(lrcContent.toString());
      print('Saved lyrics to: $lrcPath');
      return true;
    } catch (e) {
      print('Error saving lyrics: $e');
      return false;
    }
  }
}
