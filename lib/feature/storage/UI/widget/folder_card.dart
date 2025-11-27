import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:volum/app/vtext.dart';
import 'package:volum/app/vtestsmall.dart';

class FolderCard extends StatelessWidget {
  final String folderName;
  final String songCount;
  final VoidCallback? onTap;

  const FolderCard({
    Key? key,
    required this.folderName,
    required this.songCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 318.w,
        height: 48.h,
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            // Folder icon
            SvgPicture.asset(
              'assets/images/Frame.svg',
              width: 48.w,
              height: 48.h,
            ),

            SizedBox(width: 12.w),

            // Folder info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VText(
                    text: folderName,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  VTextSmall(
                    text: songCount,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
