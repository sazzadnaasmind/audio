import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtext.dart';
import 'package:volum/app/vtestsmall.dart';
import '../../../../app/resourse.dart';
class SongCard extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final String image;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.image,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: R.color.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: R.color.royalBlue.withValues(alpha: 0.2),
              offset: Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Song image
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Icon(
                  Icons.music_note,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 30.sp,
                ),
              ),
            ),
            SizedBox(width: 15.w),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VText(text: title,overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 4.h),
                  VTextSmall(text: artist,overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            VText(
              text: duration,
              fontSize: 12,
            ),
            if (onFavoriteToggle != null) ...[
              SizedBox(width: 15.w),
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? R.color.white : R.color.white,
                  size: 16.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
