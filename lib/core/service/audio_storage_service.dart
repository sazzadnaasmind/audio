import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/audio_song.dart';

class AudioStorageService {
  static const String _storageKey = 'audio_songs';

  // Request storage permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request multiple permissions for Android 13+
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.audio,
      ].request();

      // Check if any permission is granted
      return statuses.values.any((status) => status.isGranted);
    }
    return true;
  }

  // Upload audio file
  Future<AudioSong?> uploadAudioFile() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Permission denied');
        return null;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Copy file to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${appDir.path}/Music');
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }

        final newPath = '${musicDir.path}/$fileName';
        await file.copy(newPath);

        // Extract title and artist from filename
        String title = fileName
            .replaceAll(RegExp(r'\.(mp3|m4a|wav|aac|opus|flac)$', caseSensitive: false), '')
            .trim();
        String artist = 'Unknown Artist';

        // Try to extract artist from filename if it contains " - "
        if (title.contains(' - ')) {
          final parts = title.split(' - ');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            title = parts[1].trim();
          }
        }

        // Calculate accurate duration based on file size and bitrate
        String duration = '3:00';
        try {
          final fileSize = await file.length();
          // Formula: (fileSize in bytes * 8) / (bitrate in kbps * 1000)
          // Using 128 kbps as average bitrate for MP3
          final estimatedSeconds = (fileSize * 8) ~/ (128 * 1000);
          final minutes = estimatedSeconds ~/ 60;
          final seconds = estimatedSeconds % 60;
          duration = '$minutes:${seconds.toString().padLeft(2, '0')}';
        } catch (e) {
          print('Error calculating duration: $e');
        }

        // Create AudioSong object
        final song = AudioSong(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          artist: artist,
          filePath: newPath,
          folderName: 'Music',
          duration: duration,
          addedDate: DateTime.now(),
        );

        // Save to local storage
        await saveSong(song);
        return song;
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }

  // Save song to local storage
  Future<void> saveSong(AudioSong song) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getAllSongs();
    songs.add(song);

    final jsonList = songs.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Get all songs
  Future<List<AudioSong>> getAllSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => AudioSong.fromJson(json)).toList();
  }

  // Get songs by folder
  Future<List<AudioSong>> getSongsByFolder(String folderName) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.folderName == folderName).toList();
  }

  // Delete a song
  Future<void> deleteSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getAllSongs();

    // Find and delete the file
    final song = songs.firstWhere((s) => s.id == songId);
    final file = File(song.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Remove from list
    songs.removeWhere((s) => s.id == songId);

    final jsonList = songs.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Scan device for audio files in specific folders
  Future<List<AudioSong>> scanDeviceAudio(String folderName) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Permission denied for scanning');
        return [];
      }

      List<AudioSong> songs = [];

      if (Platform.isAndroid) {
        // Common Android audio paths
        final List<String> searchPaths = [
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
          '/storage/emulated/0/Telegram/Telegram Audio',
          '/storage/emulated/0/Snapchat',
          '/storage/emulated/0/SnapTube',
          '/storage/emulated/0/Recordings',
          '/storage/emulated/0/Voice Recorder',
          '/storage/emulated/0/DCIM/Recordings',
        ];

        List<String> targetPaths = [];

        switch (folderName.toLowerCase()) {
          case 'snaptuebe':
          case 'snaptube':
            targetPaths = [
              '/storage/emulated/0/SnapTube',
              '/storage/emulated/0/Snapchat',
              '/storage/emulated/0/SnapTube/Audio',
            ];
            break;
          case 'whatsapp':
            targetPaths = [
              '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
              '/storage/emulated/0/WhatsApp/Media/WhatsApp Voice Notes',
            ];
            break;
          case 'telegram':
            targetPaths = [
              '/storage/emulated/0/Telegram/Telegram Audio',
              '/storage/emulated/0/Telegram/Audio',
            ];
            break;
          case 'downloads':
            targetPaths = [
              '/storage/emulated/0/Download',
              '/storage/emulated/0/Downloads',
            ];
            break;
          case 'recorded':
            targetPaths = [
              '/storage/emulated/0/Recordings',
              '/storage/emulated/0/Voice Recorder',
              '/storage/emulated/0/DCIM/Recordings',
              '/storage/emulated/0/Recorder',
            ];
            break;
          default:
            targetPaths = ['/storage/emulated/0/Music'];
        }

        // Scan all target paths
        for (String targetPath in targetPaths) {
          final directory = Directory(targetPath);

          try {
            if (await directory.exists()) {
              print('Scanning folder: $targetPath');
              final files = directory.listSync(recursive: true);

              for (var file in files) {
                if (file is File) {
                  final ext = file.path.split('.').last.toLowerCase();
                  if (['mp3', 'm4a', 'wav', 'aac', 'opus', 'flac', 'ogg', 'wma', 'amr', '3gp'].contains(ext)) {
                    final fileName = file.path.split('/').last;
                    String title = fileName.replaceAll('.$ext', '');
                    String artist = 'Unknown Artist';

                    // Try to extract artist from filename
                    if (title.contains(' - ')) {
                      final parts = title.split(' - ');
                      if (parts.length >= 2) {
                        artist = parts[0].trim();
                        title = parts[1].trim();
                      }
                    }

                    // Get actual duration if possible
                    String duration = '3:00';
                    try {
                      final fileStats = await file.stat();
                      final fileSizeInMB = fileStats.size / (1024 * 1024);
                      // More accurate estimation: Average bitrate ~128kbps
                      // Formula: (fileSize in bytes * 8) / (bitrate in kbps * 1000)
                      final fileSizeInBytes = fileStats.size;
                      final estimatedSeconds = (fileSizeInBytes * 8) ~/ (128 * 1000);
                      final minutes = estimatedSeconds ~/ 60;
                      final seconds = estimatedSeconds % 60;
                      duration = '${minutes}:${seconds.toString().padLeft(2, '0')}';
                    } catch (e) {
                      print('Error getting file stats: $e');
                    }

                    songs.add(AudioSong(
                      id: file.path.hashCode.toString(),
                      title: title,
                      artist: artist,
                      filePath: file.path,
                      folderName: folderName,
                      duration: duration,
                      addedDate: DateTime.now(),
                    ));
                  }
                }
              }
            }
          } catch (e) {
            print('Error scanning $targetPath: $e');
          }
        }
      }

      print('Found ${songs.length} songs in $folderName');
      return songs;
    } catch (e) {
      print('Error scanning device: $e');
      return [];
    }
  }
}


