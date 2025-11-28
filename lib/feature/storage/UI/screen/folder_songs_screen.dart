import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:volum/app/vtext.dart';
import 'package:volum/app/vtestsmall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/resourse.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/service/audio_storage_service.dart';
import '../../../lyrics/UI/screen/lyrics_screen.dart';
import '../../../lyrics/UI/screen/lyrics_screen_new.dart';

class FolderSongsScreen extends StatefulWidget {
  final String folderName;

  const FolderSongsScreen({super.key, required this.folderName});

  @override
  State<FolderSongsScreen> createState() => _FolderSongsScreenState();
}

class _FolderSongsScreenState extends State<FolderSongsScreen> {
  final AudioStorageService _audioService = AudioStorageService();
  List<AudioSong> _songs = [];
  bool _isLoading = true;
  Set<String> _favoriteSongs = {}; // Track favorite songs

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _loadFavorites();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);

    // For Music folder, load uploaded songs
    if (widget.folderName == 'Music') {
      final uploadedSongs = await _audioService.getSongsByFolder('Music');
      setState(() {
        _songs = uploadedSongs;
        _isLoading = false;
      });
    } else {
      // For other folders, scan device audio
      final scannedSongs = await _audioService.scanDeviceAudio(widget.folderName);
      setState(() {
        _songs = scannedSongs;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    // Load favorite songs from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_songs') ?? [];
    setState(() {
      _favoriteSongs = favorites.toSet();
    });
  }

  Future<void> _toggleFavorite(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteSongs.contains(songId)) {
        _favoriteSongs.remove(songId);
      } else {
        _favoriteSongs.add(songId);
      }
    });
    await prefs.setStringList('favorite_songs', _favoriteSongs.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0C35),
              Color(0xFF410D5F),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Blurred gradient overlay
            Positioned(
              top: -166.h,
              left: 38.w,
              child: Transform.rotate(
                angle: -37.15 * 3.14159 / 180,
                child: Container(
                  width: 114.38.w,
                  height: 551.49.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF644FF0),
                        Color(0xFF644FF0).withValues(alpha: 0.45),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(69.r),
                  ),
                ),
              ),
            ),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 115.2, sigmaY: 115.2),
              child: Container(color: Colors.transparent),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8.w),
                        VText(
                          text: widget.folderName,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Song count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: VTextSmall(
                        text: '${_songs.length} Songs Found',
                        fontSize: 14.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Songs list
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF644FF0),
                            ),
                          )
                        : _songs.isEmpty
                            ? Center(
                                child: VText(
                                  text: 'No songs found',
                                  fontSize: 16.sp,
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                itemCount: _songs.length,
                                itemBuilder: (context, index) {
                                  final song = _songs[index];
                                  return _buildSongCard(song);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(AudioSong song) {
    final isFavorite = _favoriteSongs.contains(song.id);
    return GestureDetector(
      onTap: () {
        Get.to(() => LyricsScreen(song: song));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Album art placeholder
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Color(0xFF644FF0).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VText(
                    text: song.title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  VTextSmall(
                    text: song.artist,
                    fontSize: 13.sp,
                  ),
                ],
              ),
            ),
            // Duration
            VTextSmall(
              text: song.duration,
              fontSize: 13.sp,
            ),
            SizedBox(width: 8.w),
            // Favorite button
            GestureDetector(
              onTap: () {
                _toggleFavorite(song.id);
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.white : Colors.white,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
