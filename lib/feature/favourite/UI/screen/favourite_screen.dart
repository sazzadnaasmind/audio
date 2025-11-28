import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import '../../../../app/resourse.dart';
import '../../../../app/vtestsmall.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/service/audio_storage_service.dart';
import '../../../home/UI/widget/song_card.dart';
import '../../../lyrics/UI/screen/lyrics_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final AudioStorageService _storageService = AudioStorageService();
  List<AudioSong> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFavoriteSongs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload when app comes back to foreground
      _loadFavoriteSongs();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data whenever the screen becomes visible
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await _storageService.getFavoriteSongs();
      setState(() {
        _favoriteSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite songs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(AudioSong song) async {
    // Toggle favorite in storage
    await _storageService.toggleFavorite(song.id);

    // Update local state without reloading
    setState(() {
      final index = _favoriteSongs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        // If toggling to unfavorite, remove from list
        if (_favoriteSongs[index].isFavorite) {
          _favoriteSongs.removeAt(index);
        } else {
          // Update the song state
          _favoriteSongs[index] = _favoriteSongs[index].copyWith(
            isFavorite: !_favoriteSongs[index].isFavorite,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
            // Blurred gradient overlay layer
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

            // Apply blur to entire background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 115.2, sigmaY: 115.2),
              child: Container(
                color: Colors.transparent,
              ),
            ),

            _buildAllSongsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllSongsContent() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Container(
            width: 350.w,
            height: 52.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99.r),
              border: Border.all(
                color: R.color.slateBlue.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/search.svg',
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF696C8D),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 6.w),
                VTextSmall(
                  text: 'Search by song',
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // Song list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _favoriteSongs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80.sp,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 20.h),
                          VTextSmall(
                            text: 'No favorite songs yet',
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 10.h),
                          VTextSmall(
                            text: 'Add songs to favorites to see them here',
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: _favoriteSongs.length,
                      itemBuilder: (context, index) {
                        final song = _favoriteSongs[index];
                        return SongCard(
                          title: song.title,
                          artist: song.artist,
                          duration: song.duration,
                          image: song.filePath,
                          isFavorite: song.isFavorite,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LyricsScreen(song: song),
                              ),
                            );
                          },
                          onFavoriteToggle: () {
                            _toggleFavorite(song);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
