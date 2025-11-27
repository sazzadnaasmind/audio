import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import '../../../../app/resourse.dart';
import '../../../../app/vtestsmall.dart';
import '../../../home/UI/widget/song_card.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {

  final List<Map<String, dynamic>> songs = [
    {
      'title': 'How You Like That',
      'artist': 'Blackpink',
      'duration': '3:01',
      'image': 'assets/images/song1.jpg',
      'isFavorite': true,
    },
    {
      'title': 'As It Was',
      'artist': 'Harry Styles',
      'duration': '2:07',
      'image': 'assets/images/song2.jpg',
      'isFavorite': true,
    },
    {
      'title': 'Story of My Life',
      'artist': 'One Direction',
      'duration': '4:05',
      'image': 'assets/images/song3.jpg',
      'isFavorite': false,
    },
    {
      'title': 'Not Like Us',
      'artist': 'Kendrick Lamar',
      'duration': '4:34',
      'image': 'assets/images/song4.jpg',
      'isFavorite': false,
    },
    {
      'title': 'DAMN',
      'artist': 'Kendrick Lamar',
      'duration': '2:57',
      'image': 'assets/images/song5.jpg',
      'isFavorite': true,
    },
    {
      'title': 'Jailer-Hukum Lyrical',
      'artist': 'Gemini Tv',
      'duration': '3:01',
      'image': 'assets/images/song6.jpg',
      'isFavorite': false,
    },
    {
      'title': 'Jailer-Hukum Lyrical',
      'artist': 'Gemini Tv',
      'duration': '3:01',
      'image': 'assets/images/song7.jpg',
      'isFavorite': false,
    },
  ];

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
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongCard(
                title: song['title'],
                artist: song['artist'],
                duration: song['duration'],
                image: song['image'],
                isFavorite: song['isFavorite'],
                onTap: () {
                  // Handle song tap - play song
                  print('Play song: ${song['title']}');
                },
                onFavoriteToggle: () {
                  setState(() {
                    songs[index]['isFavorite'] = !song['isFavorite'];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

