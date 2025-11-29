import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:volum/app/vtext.dart';
import 'package:volum/app/vtestsmall.dart';
import '../../../../app/resourse.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/service/audio_storage_service.dart';
import '../../../lyrics/UI/screen/lyrics_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);


    if (widget.folderName == 'Music') {
      final uploadedSongs = await _audioService.getSongsByFolder('Music');
      setState(() {
        _songs = uploadedSongs;
        _isLoading = false;
      });
    } else {
      final scannedSongs = await _audioService.scanDeviceAudio(widget.folderName);
      final existingSongs = await _audioService.getAllSongs();

      List<AudioSong> mergedSongs = [];
      for (var scannedSong in scannedSongs) {
        final existingSong = existingSongs.firstWhere(
          (song) => song.filePath == scannedSong.filePath,
          orElse: () => scannedSong,
        );

        if (existingSongs.any((s) => s.filePath == scannedSong.filePath)) {
          mergedSongs.add(existingSong);
        } else {
          await _audioService.saveSong(scannedSong);
          mergedSongs.add(scannedSong);
        }
      }

      setState(() {
        _songs = mergedSongs;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(AudioSong song) async {
    await _audioService.toggleFavorite(song.id);

    setState(() {
      final index = _songs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _songs[index] = _songs[index].copyWith(
          isFavorite: !_songs[index].isFavorite,
        );
      }
    });
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
            colors: [R.color.darkNavy, R.color.plumPurple],
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
                        R.color.periwinkle,
                        R.color.periwinkle.withValues(alpha: 0.45),
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
                          icon: Icon(Icons.arrow_back, color: R.color.white),
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
                              color: R.color.periwinkle,
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
    return GestureDetector(
      onTap: () {
        // Pass the entire playlist with current index
        final currentIndex = _songs.indexOf(song);
        Get.to(() => LyricsScreen(
          song: song,
          playlist: _songs,
          initialIndex: currentIndex,
        ));
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
                color: R.color.periwinkle.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.music_note,
                color: R.color.white,
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
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  VTextSmall(
                    text: song.artist,
                    overflow: TextOverflow.ellipsis,
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
                _toggleFavorite(song);
              },
              child: Icon(
                song.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: song.isFavorite ? R.color.white : R.color.white,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
