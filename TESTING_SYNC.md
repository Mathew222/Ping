# Testing Cross-Device Sync (iPhone + Android)

## 🎯 Goal
Verify that reminders sync **automatically in real-time** between your iPhone and Android device.

## 📋 Prerequisites

1. **Both devices ready**:
   - iPhone (physical device or simulator on Mac)
   - Android (physical device or emulator)

2. **Same Supabase account** on both devices

## 🚀 Step-by-Step Testing

### Step 1: Set Up Both Devices

**On Mac (for iPhone):**
```bash
# Terminal 1 - Run on iPhone
cd c:\Users\mathe\Desktop\project\ping
flutter run -d <iphone-device-id>
```

**On Windows (for Android):**
```bash
# Terminal 2 - Run on Android
cd c:\Users\mathe\Desktop\project\ping
flutter run -d <android-device-id>
```

**Tip**: Use `flutter devices` to see available devices

### Step 2: Sign In on Both Devices

1. **iPhone**: Open app → Sign in with your email/password
2. **Android**: Open app → Sign in with **same** email/password

✅ Both devices should now show the same reminders (if any exist)

### Step 3: Test Real-Time Sync from iPhone → Android

**On iPhone:**
1. Tap the `+` button
2. Create a reminder: "Test from iPhone"
3. Set time and save

**On Android:**
1. **Watch the screen** - no action needed!
2. **Expected**: "Test from iPhone" appears **automatically within 1-2 seconds**! ✨

### Step 4: Test Real-Time Sync from Android → iPhone

**On Android:**
1. Tap the `+` button
2. Create a reminder: "Test from Android"
3. Set time and save

**On iPhone:**
1. **Watch the screen** - no action needed!
2. **Expected**: "Test from Android" appears **automatically within 1-2 seconds**! ✨

### Step 5: Test Delete Sync

**On iPhone:**
1. Delete "Test from Android"

**On Android:**
1. **Watch the screen**
2. **Expected**: Reminder disappears **automatically**!

### Step 6: Test Edit Sync

**On Android:**
1. Edit "Test from iPhone"
2. Change title to "Edited on Android"
3. Save

**On iPhone:**
1. **Watch the screen**
2. **Expected**: Title updates to "Edited on Android" **automatically**!

## 🔄 Real-Time Sync

**No manual refresh needed!** Changes sync automatically:
- ✨ **Create** → Appears on other devices within 1-2 seconds
- ✨ **Edit** → Updates on other devices automatically
- ✨ **Delete** → Removes from other devices automatically
- ✨ **Snooze/Complete** → Status syncs in real-time

## ✅ What Should Work

| Action | Device A | Device B | Result |
|--------|----------|----------|--------|
| Create | iPhone | Android | ✅ Appears automatically (1-2s) |
| Edit | Android | iPhone | ✅ Updates automatically (1-2s) |
| Delete | iPhone | Android | ✅ Disappears automatically (1-2s) |
| Complete | Android | iPhone | ✅ Status syncs automatically |
| Snooze | iPhone | Android | ✅ Time updates automatically |

## 🐛 Troubleshooting

### Reminders Not Syncing in Real-Time?

1. **Check you're signed in** on both devices
2. **Same account?** Verify email matches
3. **Internet connection?** Both devices need active connection
4. **Wait 2-3 seconds** - real-time sync has slight delay
5. **Check Supabase dashboard** - verify data is there
6. **Check logs** - look for "SupabaseRemindersRepository" messages
7. **Restart app** - if stream disconnected, restart to reconnect

### How to Check Supabase Dashboard

1. Go to https://supabase.com
2. Open your project
3. Click **Table Editor** → **reminders**
4. You should see all reminders with `user_id`

## 📱 Quick Test Commands

```bash
# See all connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on iPhone simulator
flutter run -d iPhone

# Run on Android emulator  
flutter run -d emulator-5554

# Hot restart (after code changes)
# Press 'R' in the terminal
```

## 🎉 Success Criteria

✅ Create reminder on iPhone → Appears on Android **automatically**  
✅ Edit reminder on Android → Updates on iPhone **automatically**  
✅ Delete reminder on iPhone → Removed from Android **automatically**  
✅ Same reminders visible on both devices  
✅ User can sign in with same account on both  
✅ Sync happens within 1-2 seconds  
✅ No manual refresh needed

## 💡 Pro Tips

1. **Keep terminals open** - one for each device
2. **Watch for automatic updates** - no need to refresh!
3. **Check Supabase dashboard** - verify data is syncing
4. **Test offline mode** - turn off WiFi, create reminder, turn on WiFi (should sync when reconnected)
5. **Sign out test** - sign out on one device, reminders should stay on other

## 🔍 Debugging

If sync isn't working, check logs for:
```
SupabaseRemindersRepository: Setting up stream for user <user-id>
SupabaseRemindersRepository: Emitting X reminders to stream
SupabaseRemindersRepository: Creating reminder <id>
SupabaseRemindersRepository: Reminder created successfully
```

---

**Your app is ready for cross-device testing!** 🚀

Just run it on both devices with the same account and watch the magic happen! ✨
