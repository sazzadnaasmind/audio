import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/audio_song.dart';

class RecentSongsService {
  static const String _recentSongsKey = 'recent_songs';
  static const int _maxRecentSongs = 10;

  // Add a song to recent songs (when played)
  static Future<void> addRecentSong(AudioSong song) async {
    final prefs = await SharedPreferences.getInstance();
    List<AudioSong> recentSongs = await getRecentSongs();

    // Remove the song if it already exists (to avoid duplicates)
    recentSongs.removeWhere((s) => s.id == song.id);

    // Add the song to the beginning of the list
    recentSongs.insert(0, song);

    // Keep only the last 10 songs
    if (recentSongs.length > _maxRecentSongs) {
      recentSongs = recentSongs.sublist(0, _maxRecentSongs);
    }

    // Save to SharedPreferences
    final jsonList = recentSongs.map((s) => s.toJson()).toList();
    await prefs.setString(_recentSongsKey, jsonEncode(jsonList));
  }

  // Get all recent songs (max 10)
  static Future<List<AudioSong>> getRecentSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recentSongsKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => AudioSong.fromJson(json)).toList();
    } catch (e) {
      print('Error loading recent songs: $e');
      return [];
    }
  }

  // Clear all recent songs
  static Future<void> clearRecentSongs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSongsKey);
  }
}

