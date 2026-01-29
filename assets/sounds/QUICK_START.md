# Quick Guide: Adding Notification Sounds

## Current Status

✅ **Sound preview now works!** 
- Plays system click sound as fallback
- Will play custom MP3 files once added

## Option 1: Quick Test (Works Now!)

The app now plays a **system click sound** when you tap the play button. This gives you immediate feedback!

**Try it:**
1. Hot restart the app (press `R` in terminal)
2. Go to Settings → Notifications → Notification Sound
3. Tap the play button (▶) - you'll hear a click!

## Option 2: Add Custom MP3 Sounds (Recommended)

### Step 1: Download Free Sounds

Visit these websites and download 1-3 second notification sounds:

**Recommended Sites:**
- **Pixabay**: https://pixabay.com/sound-effects/search/notification/
  - Free, no attribution required
  - High quality sounds
  
- **Mixkit**: https://mixkit.co/free-sound-effects/notification/
  - Free for commercial use
  - Professional quality

- **FreeSound**: https://freesound.org/
  - Requires free account
  - Huge library

### Step 2: Rename Downloaded Files

Rename your downloaded MP3 files to match these names:
- `gentle_chime.mp3` - Soft, pleasant sound
- `classic_bell.mp3` - Traditional bell
- `digital_beep.mp3` - Modern beep
- `urgent_alert.mp3` - Attention-grabbing sound

### Step 3: Add to Project

**Copy the files to:**
```
c:\Users\mathe\Desktop\project\ping\assets\sounds\
```

Make sure the files are:
- ✅ MP3 format
- ✅ 1-5 seconds long
- ✅ Under 500KB each
- ✅ Named exactly as shown above

### Step 4: Test

1. **Hot restart** the app (press `R` in terminal)
2. Go to Settings → Notifications → Notification Sound
3. Tap the play button (▶)
4. You should hear your custom sound!

## Quick Download Links

Here are some good search terms to find sounds:

1. **Gentle Chime**: Search "gentle notification chime"
2. **Classic Bell**: Search "notification bell"
3. **Digital Beep**: Search "digital notification beep"
4. **Urgent Alert**: Search "urgent notification alert"

## Troubleshooting

### Sound not playing?
- Check that files are in `assets/sounds/` directory
- Verify file names match exactly (case-sensitive)
- Make sure files are MP3 format
- Hot restart the app (press `R`)

### System click sound playing instead?
- This means MP3 files aren't found
- Check file names and location
- Hot restart after adding files

## Example: Quick Setup

1. Go to https://pixabay.com/sound-effects/search/notification/
2. Download 4 notification sounds you like
3. Rename them to match the required names
4. Copy to `assets/sounds/` folder
5. Hot restart app
6. Test in Settings!

**Time needed:** ~5 minutes

---

**Current Behavior:** System click sound (works now!)
**After adding MP3s:** Custom notification sounds (better experience!)
