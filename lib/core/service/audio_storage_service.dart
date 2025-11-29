import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/audio_song.dart';

class AudioStorageService {
  static const String _storageKey = 'audio_songs';
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.audio,
      ].request();
      return statuses.values.any((status) => status.isGranted);
    }
    return true;
  }

  Future<AudioSong?> uploadAudioFile() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        return null;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        final appDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${appDir.path}/Music');
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }

        final newPath = '${musicDir.path}/$fileName';
        await file.copy(newPath);

        String title = fileName
            .replaceAll(RegExp(r'\.(mp3|m4a|wav|aac|opus|flac)$', caseSensitive: false), '')
            .trim();
        String artist = 'Unknown Artist';

        if (title.contains(' - ')) {
          final parts = title.split(' - ');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            title = parts[1].trim();
          }
        }

        String duration = '3:00';
        try {
          final fileSize = await file.length();
          final estimatedSeconds = (fileSize * 8) ~/ (128 * 1000);
          final minutes = estimatedSeconds ~/ 60;
          final seconds = estimatedSeconds % 60;
          duration = '$minutes:${seconds.toString().padLeft(2, '0')}';
        } catch (e) {
          if (kDebugMode) {
            print('Error calculating duration: $e');
          }
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

        await saveSong(song);
        return song;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading audio file: $e');
      }
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
        return [];
      }

      List<AudioSong> songs = [];

      if (Platform.isAndroid) {
        List<String> targetPaths = [];

        switch (folderName.toLowerCase()) {
          case 'snaptuebe':
          case 'snaptube':
            targetPaths = [
              '/storage/emulated/0/SnapTube',
              '/storage/emulated/0/Snapchat',
              '/storage/emulated/0/SnapTube/Audio',
              '/storage/emulated/0/snaptube',
            ];
            break;
          case 'whatsapp':
            targetPaths = [
              '/storage/emulated/0/Music/WhatsApp',
              '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
              '/storage/emulated/0/WhatsApp/Media/WhatsApp Voice Notes',
              '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio',
              '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes',
            ];
            break;
          case 'telegram':
            targetPaths = [
              '/storage/emulated/0/Music/Telegram',
              '/storage/emulated/0/Telegram/Telegram Audio',
              '/storage/emulated/0/Telegram/Audio',
              '/storage/emulated/0/Telegram',
              '/storage/emulated/0/Android/data/org.telegram.messenger/files/Telegram/Telegram Audio',
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
              '/storage/emulated/0/SoundRecorder',
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
              // List files with error handling
              try {
                final files = await directory.list(recursive: true).toList();
                int fileCount = 0;

                for (var file in files) {
                  if (file is File) {
                    final ext = file.path.split('.').last.toLowerCase();
                    if (['mp3', 'm4a', 'wav', 'aac', 'opus', 'flac', 'ogg', 'wma', 'amr', '3gp', 'oga'].contains(ext)) {
                      fileCount++;
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
                        final fileSizeInBytes = fileStats.size;
                        final estimatedSeconds = (fileSizeInBytes * 8) ~/ (128 * 1000);
                        final minutes = estimatedSeconds ~/ 60;
                        final seconds = estimatedSeconds % 60;
                        duration = '$minutes:${seconds.toString().padLeft(2, '0')}';
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error getting file stats: $e');
                        }
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
                if (kDebugMode) {
                  print('  Found $fileCount audio files in $targetPath');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('  Error reading files in $targetPath: $e');
                }
              }
            } else {
              if (kDebugMode) {
                print('✗ Folder not found: $targetPath');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('✗ Error accessing $targetPath: $e');
            }
          }
        }
      } else if (Platform.isIOS) {
        // iOS implementation
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          List<String> targetPaths = [];

          switch (folderName.toLowerCase()) {
            case 'music':
              // Check app's document directory and iOS Music library
              targetPaths = [
                '${appDocDir.path}/Music',
                appDocDir.path,
              ];
              break;
            case 'downloads':
              targetPaths = [
                '${appDocDir.path}/Downloads',
                '${appDocDir.path}/Inbox',
              ];
              break;
            case 'recorded':
              targetPaths = [
                '${appDocDir.path}/Recordings',
                '${appDocDir.path}/Voice Memos',
              ];
              break;
            case 'whatsapp':
            case 'telegram':
            case 'snaptuebe':
              targetPaths = [
                '${appDocDir.path}/$folderName',
              ];
              break;
            default:
              targetPaths = [appDocDir.path];
          }

          // Scan all target paths
          for (String targetPath in targetPaths) {
            final directory = Directory(targetPath);

            try {
              if (await directory.exists()) {
                try {
                  final files = await directory.list(recursive: true).toList();
                  int fileCount = 0;
                  for (var file in files) {
                    if (file is File) {
                      final ext = file.path.split('.').last.toLowerCase();
                      if (['mp3', 'm4a', 'wav', 'aac', 'opus', 'flac', 'ogg', 'wma', 'amr', '3gp', 'oga', 'caf'].contains(ext)) {
                        fileCount++;
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

                        // Get actual duration
                        String duration = '3:00';
                        try {
                          final fileStats = await file.stat();
                          final fileSizeInBytes = fileStats.size;
                          final estimatedSeconds = (fileSizeInBytes * 8) ~/ (128 * 1000);
                          final minutes = estimatedSeconds ~/ 60;
                          final seconds = estimatedSeconds % 60;
                          duration = '$minutes:${seconds.toString().padLeft(2, '0')}';
                        } catch (e) {
                          if (kDebugMode) {
                            print('Error getting file stats: $e');
                          }
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
                } catch (e) {
                  if (kDebugMode) {
                    print('  Error reading files in iOS path $targetPath: $e');
                  }
                }
              } else {}
            } catch (e) {
              if (kDebugMode) {
                print('✗ Error accessing iOS path $targetPath: $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting iOS directories: $e');
          }
        }
      }
      return songs;
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning device: $e');
      }
      return [];
    }
  }

  // Toggle favorite status for a song
  Future<void> toggleFavorite(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getAllSongs();

    final index = songs.indexWhere((s) => s.id == songId);
    if (index != -1) {
      songs[index] = songs[index].copyWith(isFavorite: !songs[index].isFavorite);

      final jsonList = songs.map((s) => s.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }

  // Get all favorite songs
  Future<List<AudioSong>> getFavoriteSongs() async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.isFavorite).toList();
  }

  // Update a song (useful for updating lyrics or other fields)
  Future<void> updateSong(AudioSong updatedSong) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getAllSongs();

    final index = songs.indexWhere((s) => s.id == updatedSong.id);
    if (index != -1) {
      songs[index] = updatedSong;

      final jsonList = songs.map((s) => s.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }
}
