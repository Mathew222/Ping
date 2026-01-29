# Adding Notification Sound Files

## Quick Setup

Since we can't automatically download sound files, you need to add them manually:

### Option 1: Use System Default Sounds (Temporary)
For now, the app will use Android/iOS system default sounds. The code is ready, but you need to add actual MP3 files.

### Option 2: Add Custom MP3 Files

1. **Download free notification sounds** from:
   - https://pixabay.com/sound-effects/search/notification/
   - https://freesound.org/
   - https://mixkit.co/free-sound-effects/notification/

2. **Required files** (save to `assets/sounds/`):
   - `gentle_chime.mp3` - Soft, pleasant chime
   - `classic_bell.mp3` - Traditional bell
   - `digital_beep.mp3` - Modern beep
   - `urgent_alert.mp3` - Urgent sound

3. **File requirements**:
   - Format: MP3
   - Duration: 1-3 seconds
   - Size: < 500KB each

### Option 3: Use Android Raw Resources (Recommended for Android)

For Android, you can use raw resources:

1. Create `android/app/src/main/res/raw/` directory
2. Add MP3 files there (same names as above, but without `.mp3` extension)
3. The app will automatically use them

## Testing

After adding sound files:

1. Hot restart the app (press `R` in terminal)
2. Go to Settings → Notifications → Notification Sound
3. Select a sound
4. Create a test reminder
5. Wait for notification to verify sound plays

## Current Status

✅ Code is complete and ready
⚠️ Sound files need to be added manually
✅ App will use system default until files are added

## Quick Test Without Sound Files

You can test the feature now - it will use the system default notification sound until you add custom MP3 files.
