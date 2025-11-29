import 'package:flutter/foundation.dart';
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
  List<AudioSong> _filteredSongs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavoriteSongs();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorite songs: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSongs(String query) {
    final filtered = _favoriteSongs.where((song) {
      final titleLower = song.title.toLowerCase();
      final artistLower = song.artist.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) ||
          artistLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredSongs = filtered;
    });
  }

  Future<void> _toggleFavorite(AudioSong song) async {
    // Toggle favorite in storage
    await _storageService.toggleFavorite(song.id);

    // Update local state without reloading
    setState(() {
      final index = _favoriteSongs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        if (_favoriteSongs[index].isFavorite) {
          _favoriteSongs.removeAt(index);
          final filteredIndex = _filteredSongs.indexWhere(
            (s) => s.id == song.id,
          );
          if (filteredIndex != -1) {
            _filteredSongs.removeAt(filteredIndex);
          }
        } else {
          _favoriteSongs[index] = _favoriteSongs[index].copyWith(
            isFavorite: !_favoriteSongs[index].isFavorite,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                        R.color.periwinkle,
                        R.color.periwinkle.withValues(alpha: 0.45),
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
              child: Container(color: Colors.transparent),
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
                    R.color.slateBlue,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: R.color.periwinkle,
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by song',
                      hintStyle: TextStyle(
                        color: R.color.slateBlue,
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

        // Song list
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: R.color.white))
              : _filteredSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isEmpty
                            ? Icons.favorite_border
                            : Icons.search_off,
                        size: 80.sp,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 20.h),
                      VTextSmall(
                        text: _searchController.text.isEmpty
                            ? 'No favorite songs yet'
                            : 'No songs found',
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10.h),
                      VTextSmall(
                        text: _searchController.text.isEmpty
                            ? 'Add songs to favorites to see them here'
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
                    // Find the index of this song in the full playlist
                    final fullPlaylistIndex = _favoriteSongs.indexWhere(
                      (s) => s.id == song.id,
                    );

                    return SongCard(
                      title: song.title,
                      artist: song.artist,
                      duration: song.duration,
                      image: song.filePath,
                      isFavorite: song.isFavorite,
                      onTap: () {
                        // Pass the entire full playlist with correct index
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LyricsScreen(
                              song: song,
                              playlist: _favoriteSongs,
                              initialIndex: fullPlaylistIndex >= 0
                                  ? fullPlaylistIndex
                                  : index,
                            ),
                          ),
                        ).then((_) {
                          // Reload favorite songs when returning from LyricsScreen
                          _loadFavoriteSongs();
                        });
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
