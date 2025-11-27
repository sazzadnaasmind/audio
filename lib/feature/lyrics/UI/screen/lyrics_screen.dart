import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtestsmall.dart';
import 'dart:ui';

import 'package:volum/app/vtext.dart';
import '../../../../app/resourse.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  bool _showTranslationMenu = false;
  String _selectedLanguage = 'English';

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
              Color(0xFF1E1B4B),
              Color(0xFF4C1D95),
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

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with title and close button
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            padding: EdgeInsets.only(
                              top: 6.h,
                              right: 15.w,
                              bottom: 6.h,
                              left: 5.w,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Song info card
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
                          // Album art
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              'assets/images/image.png',
                              width: 50.w,
                              height: 50.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Song info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                VText(text: 'How You Like That',),
                                SizedBox(height: 4.h),

                                VTextSmall(text:  'Blackpink',)
                              ],
                            ),
                          ),
                          VTextSmall(text:  '3:01',),
                          SizedBox(width: 12.w),
                          // Menu icon
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showTranslationMenu = !_showTranslationMenu;
                              });
                            },
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Scrollable lyrics
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            0,
                          ),
                          SizedBox(height: 30.h),
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            1,
                          ),
                          SizedBox(height: 30.h),
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            2,
                          ),
                          SizedBox(height: 30.h),
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            3,
                          ),
                          SizedBox(height: 30.h),
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            4,
                          ),
                          SizedBox(height: 30.h),
                          _buildLyricBlock(
                            'The story of my life, I take her home\nI drive all night to keep her warm',
                            'আমার জীবনের গল্প—আমি তাকে বাড়ি নিয়ে যাই\nতাকে উষ্ণ রাখতে আমি সারারাত গাড়ি চালাই',
                            5,
                          ),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Translation Menu
            if (_showTranslationMenu)
              Positioned(
                top: 71.h,
                left: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 240.w,
                    height: 633.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF171616),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.expand_more,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Translate to: $_selectedLanguage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language List
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _languages.map((language) {
                                bool isSelected = language == _selectedLanguage;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedLanguage = language;
                                      _showTranslationMenu = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          language,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white.withValues(alpha: 0.5),
                                            fontSize: 15.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
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

            // Bottom player controls
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
                    colors: [
                      Colors.transparent,
                      Color(0xFF1E1B4B).withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Repeat button
                    IconButton(
                      icon: Icon(Icons.repeat, color: Colors.white),
                      iconSize: 28.sp,
                      onPressed: () {},
                    ),
                    // Previous button
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: 36.sp,
                      onPressed: () {},
                    ),
                    // Play/Pause button
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.pause, color: Colors.white),
                        iconSize: 40.sp,
                        onPressed: () {},
                      ),
                    ),
                    // Next button
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      iconSize: 36.sp,
                      onPressed: () {},
                    ),
                    // Shuffle button
                    IconButton(
                      icon: Icon(Icons.shuffle, color: Colors.white),
                      iconSize: 28.sp,
                      onPressed: () {},
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

  Widget _buildLyricBlock(String englishLyric, String bengaliLyric, int index) {
    // Only index 1 (second block) will be white, all others will be grayPurple
    Color textColor = index == 1 ? Colors.white : R.color.grayPurple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VText(
          text: englishLyric,
          color: textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 12.h),
        VText(
          text: bengaliLyric,
          color: textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
