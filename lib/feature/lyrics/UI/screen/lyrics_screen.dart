import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtestsmall.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:volum/app/vtext.dart';
import '../../../../app/resourse.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/model/lyric_line.dart';
import '../../../../core/service/lyrics_service.dart';
import '../../../../core/service/recent_songs_service.dart';

class LyricsScreen extends StatefulWidget {
  final AudioSong? song;

  const LyricsScreen({super.key, this.song});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  bool _showTranslationMenu = false;
  String _selectedLanguage = 'English';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentLyricIndex = -1;
  final ScrollController _scrollController = ScrollController();
  List<String> _availableLanguages = ['English'];
  List<LyricLine> _lyrics = [];
  bool _isLoadingLyrics = true;

  final List<String> _languages = [
    'English',
    'Bangla',
    'Chinese',
    'French',
    'Arabic',
    'Urdu',
    'Japanese',
    'Korean',
    'Portuguese',
    'German',
    'Spanish',
    'Italian',
    'Russian',
  ];

  @override
  void initState() {
    super.initState();
    _loadLyrics();
    _initAudioPlayer();
    _addToRecentSongs();
  }

  Future<void> _addToRecentSongs() async {
    if (widget.song != null) {
      await RecentSongsService.addRecentSong(widget.song!);
    }
  }

  Future<void> _loadLyrics() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLyrics = true;
    });

    try {
      if (widget.song?.lyrics != null && widget.song!.lyrics!.isNotEmpty) {
        _lyrics = widget.song!.lyrics!;
      } else if (widget.song != null) {
        final fetchedLyrics = await LyricsService.fetchLyrics(widget.song!);
        if (fetchedLyrics != null && fetchedLyrics.isNotEmpty) {
          _lyrics = fetchedLyrics;

          // Save fetched lyrics to local .lrc file for future use
          LyricsService.saveLyricsToFile(widget.song!.filePath, fetchedLyrics);
        }
      }

      _detectAvailableLanguages();
    } catch (e) {
      print('Error loading lyrics: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLyrics = false;
        });
      }
    }
  }

  void _detectAvailableLanguages() {
    if (_lyrics.isNotEmpty) {
      Set<String> languages = {'English'};
      for (var line in _lyrics) {
        languages.addAll(line.translations.keys);
      }
      _availableLanguages = languages.toList();

      if (_availableLanguages.length > 1) {
        for (var lang in _availableLanguages) {
          if (lang != 'English') {
            _selectedLanguage = lang;
            break;
          }
        }
      }
    }
  }

  void _initAudioPlayer() {
    if (widget.song != null) {
      _audioPlayer.setSourceDeviceFile(widget.song!.filePath);

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration);
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
            _updateCurrentLyric();
          });
        }
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state == PlayerState.playing);
        }
      });

      _audioPlayer.resume();
    }
  }

  void _updateCurrentLyric() {
    if (_lyrics.isEmpty || !mounted) return;

    int currentSeconds = _position.inSeconds;
    int newIndex = -1;

    for (int i = 0; i < _lyrics.length; i++) {
      if (currentSeconds >= _lyrics[i].timestamp) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != _currentLyricIndex) {
      setState(() {
        _currentLyricIndex = newIndex;
      });
      _scrollToCurrentLyric();
    }
  }

  void _scrollToCurrentLyric() {
    if (_currentLyricIndex >= 0 && _scrollController.hasClients) {
      double targetPosition = _currentLyricIndex * 120.h;
      _scrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songTitle = widget.song?.title ?? 'How You Like That';
    final songArtist = widget.song?.artist ?? 'Blackpink';
    final songDuration = _duration != Duration.zero ? _formatDuration(_duration) : (widget.song?.duration ?? '3:01');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF4C1D95),
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
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        VText(
                          text: 'Lyrics',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            padding: EdgeInsets.only(top: 6.h, right: 15.w, bottom: 6.h, left: 5.w),
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Container(
                      width: 350.w,
                      height: 82.h,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF000000).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3064BF).withValues(alpha: 0.2),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset('assets/images/image.png', width: 50.w, height: 50.h, fit: BoxFit.cover),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                VText(text: songTitle),
                                SizedBox(height: 4.h),
                                VTextSmall(text: songArtist),
                              ],
                            ),
                          ),
                          VTextSmall(text: songDuration),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () => setState(() => _showTranslationMenu = !_showTranslationMenu),
                            child: Icon(Icons.more_vert, color: Colors.white, size: 20.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Expanded(
                    child: _isLoadingLyrics
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16.h),
                                VText(text: 'Loading lyrics...', color: Colors.white, fontSize: 14.sp),
                              ],
                            ),
                          )
                        : _lyrics.isEmpty
                            ? Center(child: VText(text: 'No lyrics available for this song', color: R.color.grayPurple, fontSize: 16.sp))
                            : SingleChildScrollView(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(_lyrics.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 30.h),
                                        child: _buildLyricBlock(_lyrics[index], index),
                                      );
                                    }),
                                    SizedBox(height: 120.h),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
            ),
            if (_showTranslationMenu)
              Positioned(
                top: 71.h,
                left: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 240.w,
                    height: 633.h,
                    decoration: BoxDecoration(color: Color(0xFF171616)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.expand_more, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Translate to: $_selectedLanguage',
                                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _languages.map((language) {
                                bool isSelected = language == _selectedLanguage;
                                bool isAvailable = _availableLanguages.contains(language);
                                return InkWell(
                                  onTap: isAvailable
                                      ? () => setState(() {
                                            _selectedLanguage = language;
                                            _showTranslationMenu = false;
                                          })
                                      : null,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          language,
                                          style: TextStyle(
                                            color: !isAvailable
                                                ? Colors.white.withValues(alpha: 0.3)
                                                : isSelected
                                                    ? Colors.white
                                                    : Colors.white.withValues(alpha: 0.5),
                                            fontSize: 15.sp,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF1E1B4B).withValues(alpha: 0.9)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: Icon(Icons.repeat, color: Colors.white), iconSize: 28.sp, onPressed: () {}),
                    IconButton(icon: Icon(Icons.skip_previous, color: Colors.white), iconSize: 36.sp, onPressed: () {}),
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        iconSize: 40.sp,
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.skip_next, color: Colors.white), iconSize: 36.sp, onPressed: () {}),
                    IconButton(icon: Icon(Icons.shuffle, color: Colors.white), iconSize: 28.sp, onPressed: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricBlock(LyricLine lyricLine, int index) {
    bool isCurrentLine = index == _currentLyricIndex;
    Color textColor = isCurrentLine ? Colors.white : R.color.grayPurple;
    String primaryText = lyricLine.english;
    String secondaryText = _selectedLanguage != 'English' ? lyricLine.getTranslation(_selectedLanguage) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VText(text: primaryText, color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w500),
        if (secondaryText.isNotEmpty && _selectedLanguage != 'English') ...[
          SizedBox(height: 12.h),
          VText(text: secondaryText, color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w500),
        ],
      ],
    );
  }
}
