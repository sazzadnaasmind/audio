import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volum/app/vtext.dart';
import '../../../../app/resourse.dart';

class TabItem extends StatelessWidget {
  final String title;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const TabItem({
    super.key,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          VText(
            text: title,
            fontWeight: FontWeight.w500,
            color: isSelected ? R.color.white : R.color.slateBlue,
          ),
          SizedBox(height: 4.h),
          if (isSelected)
            Container(
              height: 2.h,
              width: 72.w,
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
        ],
      ),
    );
  }
}

