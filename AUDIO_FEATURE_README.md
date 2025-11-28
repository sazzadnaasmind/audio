# Audio Upload and Playback Feature

## Installation Steps

### 1. Install Required Packages
Run this command in your terminal:

```bash
flutter pub get
```

### 2. Update Android Permissions
Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions before <application> tag -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    
    <application
        ...
    >
    ...
    </application>
</manifest>
```

### 3. Update gradle.properties (if needed)
Add this line to `android/gradle.properties`:
```
android.useAndroidX=true
```

## Features Implemented

### 1. **Storage Screen with FAB**
- Floating Action Button to upload audio files
- Click to select audio file from device
- Uploaded files are stored in app's Music folder
- Shows song count for each folder

### 2. **Folder Management**
- **Music Folder**: Shows only uploaded songs via FAB
- **Other Folders** (SnapTuebe, Whatsapp, Telegram, Downloads, Recorded): 
  - Scan device for audio files in respective folders
  - Shows audio files found in those locations

### 3. **Folder Songs Screen**
- Click any folder to view its songs
- Lists all audio files in that folder
- Click on any song to play it in Lyrics Screen

### 4. **Lyrics Screen with Audio Playback**
- Receives song data from folder
- Auto-plays the audio when opened
- Play/Pause button works
- Shows song title, artist, and duration
- Translation menu (13 languages)

### 5. **Audio Restrictions**
- Songs uploaded via FAB are ONLY visible in Music folder
- Other folders show their respective device audio files
- Uploaded songs won't appear in other folders

## How to Use

1. **Upload Audio**:
   - Open Storage Screen
   - Click the purple + button (FAB)
   - Select an audio file from your device
   - Song will be uploaded to Music folder

2. **Play Uploaded Songs**:
   - Click on "Music" folder
   - See list of uploaded songs
   - Click any song to open Lyrics Screen and play

3. **Browse Other Folders**:
   - Click on SnapTuebe, Whatsapp, Telegram, Downloads, or Recorded folders
   - See audio files from those device locations
   - Click any song to play it

## Files Created/Modified

### New Files:
- `lib/core/model/audio_song.dart` - Audio song data model
- `lib/core/service/audio_storage_service.dart` - Service for audio upload and scanning
- `lib/feature/storage/UI/screen/folder_songs_screen.dart` - Screen to display folder songs

### Modified Files:
- `pubspec.yaml` - Added required packages
- `lib/feature/storage/UI/screen/storage_screen.dart` - Added FAB and upload functionality
- `lib/feature/lyrics/UI/screen/lyrics_screen.dart` - Added audio playback support

