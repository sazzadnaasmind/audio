import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtestsmall.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:volum/app/vtext.dart';
import '../../../../app/resourse.dart';
import '../../../../core/model/audio_song.dart';
import '../../../../core/service/recent_songs_service.dart';

class LyricsScreen extends StatefulWidget {
  final AudioSong? song;
  final List<AudioSong>? playlist;
  final int? initialIndex;

  const LyricsScreen({
    super.key,
    this.song,
    this.playlist,
    this.initialIndex,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Playlist management
  List<AudioSong> _playlist = [];
  int _currentSongIndex = 0;
  AudioSong? _currentSong;

  // Playback modes
  bool _isRepeatMode = false;
  bool _isShuffleMode = false;
  List<int> _shuffledIndices = [];

  @override
  void initState() {
    super.initState();
    _initializePlaylist();
    _initAudioPlayer();
    _addToRecentSongs();
  }

  void _initializePlaylist() {
    if (widget.playlist != null && widget.playlist!.isNotEmpty) {
      _playlist = List.from(widget.playlist!);
      _currentSongIndex = widget.initialIndex ?? 0;
      _currentSong = _playlist[_currentSongIndex];
    } else if (widget.song != null) {
      _playlist = [widget.song!];
      _currentSongIndex = 0;
      _currentSong = widget.song;
    }

    // Initialize shuffled indices
    _shuffledIndices = List.generate(_playlist.length, (index) => index);
  }

  Future<void> _addToRecentSongs() async {
    if (_currentSong != null) {
      await RecentSongsService.addRecentSong(_currentSong!);
    }
  }

  void _initAudioPlayer() {
    if (_currentSong != null) {
      _audioPlayer.setSourceDeviceFile(_currentSong!.filePath);

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration);
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state == PlayerState.playing);
        }
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          _onSongComplete();
        }
      });

      _audioPlayer.resume();
    }
  }

  Future<void> _onSongComplete() async {
    if (_isRepeatMode) {
      // Repeat current song
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } catch (e) {
        print('Error repeating song: $e');
        // If seek fails, reload the source
        if (_currentSong != null) {
          await _audioPlayer.setSourceDeviceFile(_currentSong!.filePath);
          await _audioPlayer.resume();
        }
      }
    } else if (_playlist.length == 1) {
      // If only one song and repeat is off, loop it anyway
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } catch (e) {
        print('Error looping song: $e');
        if (_currentSong != null) {
          await _audioPlayer.setSourceDeviceFile(_currentSong!.filePath);
          await _audioPlayer.resume();
        }
      }
    } else {
      // Play next song in playlist
      await _playNext();
    }
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeatMode = !_isRepeatMode;
      // If repeat is enabled, disable shuffle
      if (_isRepeatMode) {
        _isShuffleMode = false;
      }
    });
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleMode = !_isShuffleMode;
      // If shuffle is enabled, disable repeat
      if (_isShuffleMode) {
        _isRepeatMode = false;
        // Create shuffled indices
        _shuffledIndices = List.generate(_playlist.length, (index) => index);
        _shuffledIndices.shuffle();

        // Make sure current song is first in shuffle
        int currentIndexInShuffle = _shuffledIndices.indexOf(_currentSongIndex);
        if (currentIndexInShuffle != 0) {
          _shuffledIndices.removeAt(currentIndexInShuffle);
          _shuffledIndices.insert(0, _currentSongIndex);
        }
      } else {
        // Reset shuffled indices to normal order when shuffle is disabled
        _shuffledIndices = List.generate(_playlist.length, (index) => index);
      }
    });
  }

  Future<void> _playPrevious() async {
    if (_playlist.isEmpty) return;

    int previousIndex;
    if (_isShuffleMode) {
      int currentShufflePosition = _shuffledIndices.indexOf(_currentSongIndex);
      if (currentShufflePosition > 0) {
        previousIndex = _shuffledIndices[currentShufflePosition - 1];
      } else {
        // Loop to end
        previousIndex = _shuffledIndices.last;
      }
    } else {
      if (_currentSongIndex > 0) {
        previousIndex = _currentSongIndex - 1;
      } else {
        // Loop to end
        previousIndex = _playlist.length - 1;
      }
    }

    await _changeSong(previousIndex);
  }

  Future<void> _playNext() async {
    if (_playlist.isEmpty) return;

    int nextIndex;
    if (_isShuffleMode) {
      int currentShufflePosition = _shuffledIndices.indexOf(_currentSongIndex);
      if (currentShufflePosition < _shuffledIndices.length - 1) {
        nextIndex = _shuffledIndices[currentShufflePosition + 1];
      } else {
        // Loop to beginning
        nextIndex = _shuffledIndices.first;
      }
    } else {
      if (_currentSongIndex < _playlist.length - 1) {
        nextIndex = _currentSongIndex + 1;
      } else {
        // Loop to beginning
        nextIndex = 0;
      }
    }

    await _changeSong(nextIndex);
  }

  Future<void> _changeSong(int newIndex) async {
    await _audioPlayer.stop();

    setState(() {
      _currentSongIndex = newIndex;
      _currentSong = _playlist[_currentSongIndex];
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    await _addToRecentSongs();
    await _audioPlayer.setSourceDeviceFile(_currentSong!.filePath);
    await _audioPlayer.resume();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songTitle = _currentSong?.title ?? 'How You Like That';
    final songArtist = _currentSong?.artist ?? 'Blackpink';
    final songDuration = _duration != Duration.zero ? _formatDuration(_duration) : (_currentSong?.duration ?? '3:01');

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
                          text: 'Now Playing',
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Spacer(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: _isRepeatMode ? Color(0xFF644FF0) : Colors.white,
                      ),
                      iconSize: 28.sp,
                      onPressed: _toggleRepeat,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: 36.sp,
                      onPressed: _playlist.length > 1 ? _playPrevious : null,
                    ),
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
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      iconSize: 36.sp,
                      onPressed: _playlist.length > 1 ? _playNext : null,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: _isShuffleMode ? Color(0xFF644FF0) : Colors.white,
                      ),
                      iconSize: 28.sp,
                      onPressed: _playlist.length > 1 ? _toggleShuffle : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

