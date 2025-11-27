// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'dart:ui';
//
// import 'package:volum/app/vtext.dart';
//
// import '../../../../app/resourse.dart';
//
// class EmptyOnline extends StatefulWidget {
//   const EmptyOnline({super.key});
//
//   @override
//   State<EmptyOnline> createState() => _EmptyOnlineState();
// }
//
// class _EmptyOnlineState extends State<EmptyOnline> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF0A0C35),
//               Color(0xFF410D5F),
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Blurred gradient overlay layer
//             Positioned(
//               top: -166.h,
//               left: 38.w,
//               child: Transform.rotate(
//                 angle: -37.15 * 3.14159 / 180,
//                 child: Container(
//                   width: 114.38.w,
//                   height: 551.49.h,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Color(0xFF644FF0),
//                         Color(0xFF644FF0).withValues(alpha: 0.45),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(69.r),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Apply blur to entire background
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 115.2, sigmaY: 115.2),
//               child: Container(
//                 color: Colors.transparent,
//               ),
//             ),
//
//             // Close button at top-right
//             Positioned(
//               top: 63.h,
//               left: 328.w,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   width: 32.w,
//                   height: 32.h,
//                   padding: EdgeInsets.only(
//                     top: 6.h,
//                     right: 15.w,
//                     bottom: 6.h,
//                     left: 5.w,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFD9D9D9).withValues(alpha: 0.2),
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 20.sp,
//                   ),
//                 ),
//               ),
//             ),
//
//             // Main content
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: Column(
//                 children: [
//                   SizedBox(height: 120.h),
//
//                   // Title
//                   // Text(
//                   //   'Connect Any Music Service\nto Continue Listening',
//                   //   textAlign: TextAlign.center,
//                   //   style: TextStyle(
//                   //     color: Colors.white,
//                   //     fontSize: 28.sp,
//                   //     fontWeight: FontWeight.bold,
//                   //     height: 1.2,
//                   //   ),
//                   // ),
//                   VText(text:  'Connect Any Music Service\nto Continue Listening',
//                     fontSize: 24.sp,
//                     color: R.color.lightBlue,
//                     textAlign: TextAlign.center,
//                   ),
//
//                   SizedBox(height: 60.h),
//
//                   // Service icons grid
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // iTunes icon
//                       GestureDetector(
//                         onTap: () {
//                           // Handle iTunes connection
//                         },
//                         child: Container(
//                           width: 98.w,
//                           height: 98.h,
//                           padding: EdgeInsets.all(19.w),
//                           // decoration: BoxDecoration(
//                           //   color: Color(0xFFFFFFFF).withValues(alpha: 0.1),
//                           //   borderRadius: BorderRadius.circular(24.r),
//                           // ),
//                           child: Center(
//                             child: SvgPicture.asset(
//                               'assets/images/iTunes.svg',
//                               width: 30.w,
//                               height: 30.h,
//                               colorFilter: ColorFilter.mode(
//                                 Colors.white,
//                                 BlendMode.srcIn,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(width: 10.w),
//
//                       // Spotify icon
//                       GestureDetector(
//                         onTap: () {
//                           // Handle Spotify connection
//                         },
//                         child: Container(
//                           width: 98.w,
//                           height: 98.h,
//                           padding: EdgeInsets.all(19.w),
//                           // decoration: BoxDecoration(
//                           //   color: Color(0xFFFFFFFF).withValues(alpha: 0.1),
//                           //   borderRadius: BorderRadius.circular(24.r),
//                           // ),
//                           child: Container(
//                             width: 60.w,
//                             height: 60.h,
//                             decoration: BoxDecoration(
//                               color: Color(0xFF1DB954),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: SvgPicture.asset(
//                                 'assets/images/spotify.svg',
//                                 width: 30.w,
//                                 height: 30.h,
//                                 colorFilter: ColorFilter.mode(
//                                   Colors.white,
//                                   BlendMode.srcIn,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Bottom singer illustration
//             Positioned(
//               bottom: 0,
//               left: -3,
//               child: SvgPicture.asset(
//                 'assets/images/singer.svg',
//                 width: 396,
//                 height: 396,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
