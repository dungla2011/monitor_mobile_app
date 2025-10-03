# Quick Download: Free Notification Sounds

## 🎵 Recommended Free Sources

### 1. Mixkit (Recommended - No attribution required)
**Link:** https://mixkit.co/free-sound-effects/notification/

**Suggested downloads:**
- Alert: https://mixkit.co/free-sound-effects/alarm/ 
  - Search: "notification alert" or "alarm"
  
- Gentle: https://mixkit.co/free-sound-effects/notification/
  - Search: "soft notification" or "gentle beep"
  
- Urgent: https://mixkit.co/free-sound-effects/alarm/
  - Search: "urgent alarm" or "emergency"

### 2. Freesound (Creative Commons)
**Link:** https://freesound.org/

**Search terms:**
- "notification short"
- "notification tone"
- "notification alert"

**Filter:**
- Duration: < 3 seconds
- Format: MP3 or WAV
- License: CC0 (Public Domain) preferred

### 3. Notification Sounds
**Link:** https://notificationsounds.com/

**Categories:**
- Alert Tones
- Notification Tones
- Message Sounds

## 📥 Download Instructions

### Step 1: Download sounds
Visit one of the links above and download 3 MP3 files:
- One alert/sharp sound
- One gentle/soft sound  
- One urgent/loud sound

### Step 2: Rename files
Rename downloaded files to:
```
notification_alert.mp3    (for alert sound)
notification_gentle.mp3   (for gentle sound)
notification_urgent.mp3   (for urgent sound)
```

### Step 3: Place files
Move the renamed files to:
```
E:\Projects\MonitorApp2025\monitor_app\assets\sounds\
```

Replace the .txt placeholder files.

### Step 4: Rebuild app
```bash
cd E:\Projects\MonitorApp2025\monitor_app
flutter clean
flutter pub get
flutter build apk
```

## 🔊 Sound Specifications

**Recommended:**
- Format: MP3
- Duration: 1-3 seconds (max 5 seconds)
- File size: < 500KB each
- Bitrate: 128kbps (standard quality is enough)
- Sample rate: 44.1kHz or 48kHz

**Why these specs?**
- Short duration: Notifications should be quick
- Small size: Reduce app size
- MP3 format: Universal compatibility

## 🎨 Sound Characteristics

### Alert Sound (notification_alert.mp3)
- **Characteristics:** Clear, attention-grabbing, medium pitch
- **Use case:** General notifications, app updates
- **Examples:** "ding", "beep", "chime"
- **Suggested search:** "notification bell", "notification chime"

### Gentle Sound (notification_gentle.mp3)
- **Characteristics:** Soft, pleasant, low volume
- **Use case:** Non-urgent messages, background updates
- **Examples:** "soft ding", "water drop", "wind chime"
- **Suggested search:** "gentle notification", "soft beep", "pleasant sound"

### Urgent Sound (notification_urgent.mp3)
- **Characteristics:** Loud, alarming, repetitive or sharp
- **Use case:** Alerts, warnings, important messages
- **Examples:** "alarm", "siren", "emergency tone"
- **Suggested search:** "urgent alarm", "warning sound", "emergency notification"

## ⚡ Quick Download Links (Examples)

### From Mixkit (Free, No attribution required):

1. **Alert:** 
   - Browse: https://mixkit.co/free-sound-effects/notification/
   - Look for: "Notification bell chime" or similar
   - Download and rename to `notification_alert.mp3`

2. **Gentle:**
   - Browse: https://mixkit.co/free-sound-effects/notification/
   - Look for: "Soft notification" or "Message pop"
   - Download and rename to `notification_gentle.mp3`

3. **Urgent:**
   - Browse: https://mixkit.co/free-sound-effects/alarm/
   - Look for: "Alert alarm" or "Emergency alarm"
   - Download and rename to `notification_urgent.mp3`

## 🔧 Convert WAV to MP3 (if needed)

If you download WAV files, convert to MP3:

### Online converter (easy):
- https://cloudconvert.com/wav-to-mp3
- https://www.freeconvert.com/wav-to-mp3

### FFmpeg (for developers):
```bash
ffmpeg -i input.wav -b:a 128k -ar 44100 output.mp3
```

## ✅ Verification

After placing files, verify:

```bash
ls -la assets/sounds/
```

Should see:
```
notification_alert.mp3
notification_gentle.mp3
notification_urgent.mp3
README.md
```

## 🧪 Test Sounds

After rebuild, test in app:
1. Open app → Settings
2. Tap "Âm thanh thông báo"
3. Select each sound
4. Tap "Nghe thử" button
5. Should hear the sound play

## 📝 License Notes

**Important:** Always check license before use:

- **CC0 (Public Domain):** ✅ Free for any use, no attribution
- **CC-BY:** ✅ Free, but must give credit to author
- **Royalty-free:** ✅ Usually free, check terms
- **Copyrighted:** ❌ Do not use without permission

For commercial apps, prefer:
- CC0 (Public Domain)
- Royalty-free sounds
- Sounds with commercial use license

## 🆘 Can't find sounds?

**Alternative: Use online sound generators**

1. **MyInstants** - https://www.myinstants.com/
   - Search notification sounds
   - Download MP3

2. **Zapsplat** - https://www.zapsplat.com/
   - Free with account
   - High quality sounds
   - Search "notification"

3. **FreeSound** - https://freesound.org/
   - Community sounds
   - Various licenses
   - Filter by CC0

## 💡 Pro Tips

1. **Test on actual device:** Emulator sound may differ
2. **Keep it short:** 1-2 seconds is ideal
3. **Test volume:** Not too loud, not too soft
4. **Test with headphones:** Check stereo balance
5. **Backup originals:** Keep original files before renaming

## 🎯 Quick Start (5 minutes)

```bash
# 1. Visit Mixkit
open https://mixkit.co/free-sound-effects/notification/

# 2. Download 3 sounds (any notification sounds you like)

# 3. Rename files
mv ~/Downloads/sound1.mp3 notification_alert.mp3
mv ~/Downloads/sound2.mp3 notification_gentle.mp3
mv ~/Downloads/sound3.mp3 notification_urgent.mp3

# 4. Move to project
mv notification_*.mp3 E:/Projects/MonitorApp2025/monitor_app/assets/sounds/

# 5. Rebuild
cd E:/Projects/MonitorApp2025/monitor_app
flutter clean && flutter pub get && flutter build apk

# Done! 🎉
```

---

**Need help?** Check `GUIDE_NOTIFICATION_SOUNDS.md` for troubleshooting.
