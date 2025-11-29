import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:volum/feature/storage/UI/widget/folder_card.dart';
import 'package:volum/app/vtext.dart';
import 'package:get/get.dart';
import '../../../../app/resourse.dart';
import '../../../../core/service/audio_storage_service.dart';
import 'folder_songs_screen.dart';
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final AudioStorageService _audioService = AudioStorageService();

  List<Map<String, String>> folders = [
    {'name': 'Music', 'songs': '0 Songs'},
    {'name': 'SnapTuebe', 'songs': '0 Songs'},
    {'name': 'Whatsapp', 'songs': '0 Songs'},
    {'name': 'Telegram', 'songs': '0 Songs'},
    {'name': 'Downloads', 'songs': '0 Songs'},
    {'name': 'Recorded', 'songs': '0 Songs'},
  ];

  @override
  void initState() {
    super.initState();
    _updateAllFolderCounts();
  }

  Future<void> _updateAllFolderCounts() async {
    // Update Music folder count (uploaded songs)
    final musicSongs = await _audioService.getSongsByFolder('Music');

    // Scan other folders from device storage
    final snapTubeSongs = await _audioService.scanDeviceAudio('SnapTuebe');
    final whatsappSongs = await _audioService.scanDeviceAudio('Whatsapp');
    final telegramSongs = await _audioService.scanDeviceAudio('Telegram');
    final downloadsSongs = await _audioService.scanDeviceAudio('Downloads');
    final recordedSongs = await _audioService.scanDeviceAudio('Recorded');

    setState(() {
      folders = [
        {'name': 'Music', 'songs': '${musicSongs.length} Songs'},
        {'name': 'SnapTuebe', 'songs': '${snapTubeSongs.length} Songs'},
        {'name': 'Whatsapp', 'songs': '${whatsappSongs.length} Songs'},
        {'name': 'Telegram', 'songs': '${telegramSongs.length} Songs'},
        {'name': 'Downloads', 'songs': '${downloadsSongs.length} Songs'},
        {'name': 'Recorded', 'songs': '${recordedSongs.length} Songs'},
      ];
    });
  }

  Future<void> _uploadAudioFile() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Color(0xFF644FF0),
        ),
      ),
    );

    final song = await _audioService.uploadAudioFile();

    Navigator.pop(context);

    if (song != null) {
      await _updateAllFolderCounts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio uploaded successfully to Music folder'),
          backgroundColor: R.color.periwinkle,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload audio. Please check permissions.'),
          backgroundColor: R.color.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
            colors: [R.color.darkNavy, R.color.plumPurple],
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
                        R.color.periwinkle,
                        R.color.periwinkle.withValues(alpha: 0.45),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: VText(
                      text: '${folders.length} Folder Found',
                    ),
                  ),
                  SizedBox(height: 20.h),
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
                            Get.to(() => FolderSongsScreen(
                              folderName: folder['name']!,
                            ))?.then((_) {
                              _updateAllFolderCounts();
                            });
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
        onPressed: _uploadAudioFile,
        backgroundColor: R.color.periwinkle,
        child: Icon(
          Icons.add,
          color: R.color.white,
          size: 28.sp,
        ),
      ),
    );
  }
}
