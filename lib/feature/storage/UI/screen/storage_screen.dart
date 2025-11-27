import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtestsmall.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:volum/feature/storage/UI/widget/folder_card.dart';
import 'package:volum/app/vtext.dart';

import '../../../../app/resourse.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final List<Map<String, String>> folders = [
    {'name': 'Music', 'songs': '25 Songs'},
    {'name': 'SnapTuebe Audio', 'songs': '15 Songs'},
    {'name': 'Whatsapp Audio', 'songs': '1 Songs'},
    {'name': 'Whatsapp Audio', 'songs': '1 Songs'},
    {'name': 'Whatsapp Audio', 'songs': '1 Songs'},
    {'name': 'Whatsapp Audio', 'songs': '1 Songs'},
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
            // Blurred gradient overlay layer - no visible border
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                            text: 'Search by Folder',
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // "6 Folder Found" text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: VText(
                      text: '${folders.length} Folder Found',
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Folder list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        return FolderCard(
                          folderName: folder['name']!,
                          songCount: folder['songs']!,
                          onTap: () {
                            // Handle folder tap - open folder
                            print('Open folder: ${folder['name']}');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB tap
          print('FAB pressed');
        },
        backgroundColor: Color(0xFF644FF0),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }
}
