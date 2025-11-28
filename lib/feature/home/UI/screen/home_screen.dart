import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:volum/app/vtestsmall.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:volum/feature/home/UI/widget/tab_item.dart';
import 'package:volum/feature/home/UI/widget/song_card.dart';
import 'package:volum/feature/storage/UI/screen/storage_screen.dart';
import 'package:volum/feature/online/UI/screen/online_screen.dart' hide OnlineScreen;
import 'package:volum/feature/favourite/UI/screen/favourite_screen.dart';

import '../../../../app/resourse.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/service/recent_songs_service.dart';
import '../../../lyrics/UI/screen/lyrics_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int selectedTabIndex = 0;
  List<AudioSong> _recentSongs = [];
  List<AudioSong> _filteredSongs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRecentSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRecentSongs();
    }
  }

  Future<void> _loadRecentSongs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await RecentSongsService.getRecentSongs();
      if (mounted) {
        setState(() {
          _recentSongs = songs;
          _filteredSongs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recent songs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterSongs(String query) {
    final filtered = _recentSongs.where((song) {
      final titleLower = song.title.toLowerCase();
      final artistLower = song.artist.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) || artistLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredSongs = filtered;
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
            colors: [
              Color(0xFF0A0C35),
              Color(0xFF410D5F),
            ],
          ),
        ),
        child: Stack(
          children: [
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
              child: Container(
                color: Colors.transparent,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TabItem(
                          title: 'All Songs',
                          index: 0,
                          selectedIndex: selectedTabIndex,
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 0;
                            });
                          },
                        ),
                        TabItem(
                          title: 'Storage',
                          index: 1,
                          selectedIndex: selectedTabIndex,
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 1;
                            });
                          },
                        ),
                        TabItem(
                          title: 'Online',
                          index: 2,
                          selectedIndex: selectedTabIndex,
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 2;
                            });
                          },
                        ),
                        TabItem(
                          title: 'Favourite',
                          index: 3,
                          selectedIndex: selectedTabIndex,
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: selectedTabIndex,
                      children: [
                        _buildAllSongsContent(),
                        StorageScreen(),
                        FavouriteScreen(),
                        FavouriteScreen(),
                      ],
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

  Widget _buildAllSongsContent() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Container(
            width: 350.w,
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Color(0xFF644FF0),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by song',
                      hintStyle: TextStyle(
                        color: Color(0xFF696C8D),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      _filterSongs(value);
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _filterSongs('');
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : _filteredSongs.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchController.text.isEmpty
                      ? Icons.music_note
                      : Icons.search_off,
                  size: 80.sp,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                SizedBox(height: 20.h),
                VTextSmall(
                  text: _searchController.text.isEmpty
                      ? 'No recent songs'
                      : 'No songs found',
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10.h),
                VTextSmall(
                  text: _searchController.text.isEmpty
                      ? 'Play a song to see it here'
                      : 'Try searching with different keywords',
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _filteredSongs.length,
            itemBuilder: (context, index) {
              final song = _filteredSongs[index];
              return SongCard(
                title: song.title,
                artist: song.artist,
                duration: song.duration,
                image: song.filePath,
                isFavorite: false,
                onTap: () {
                  // Pass the entire filtered playlist with current index
                  Get.to(() => LyricsScreen(
                    song: song,
                    playlist: _filteredSongs,
                    initialIndex: index,
                  ));
                },
                onFavoriteToggle: null,
              );
            },
          ),
        ),
      ],
    );
  }
}