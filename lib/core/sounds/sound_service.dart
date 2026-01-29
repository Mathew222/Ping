import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Available notification sounds
enum NotificationSound {
  gentleChime('Gentle Chime', 'gentle_chime'),
  classicBell('Classic Bell', 'classic_bell'),
  digitalBeep('Digital Beep', 'digital_beep'),
  urgentAlert('Urgent Alert', 'urgent_alert');

  final String displayName;
  final String fileName;

  const NotificationSound(this.displayName, this.fileName);

  /// Get the sound resource name for Android notifications
  String get androidResourceName => fileName;

  /// Get the sound file name for iOS notifications
  String get iosFileName => '$fileName.mp3';
}

/// Service to manage notification sound preferences
class SoundService {
  static const String _soundPreferenceKey = 'notification_sound';

  // Audio player for previewing sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Get the currently selected notification sound
  Future<NotificationSound> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    final soundName = prefs.getString(_soundPreferenceKey);

    if (soundName == null) {
      return NotificationSound.gentleChime; // Default
    }

    // Find matching sound
    try {
      return NotificationSound.values.firstWhere(
        (sound) => sound.fileName == soundName,
      );
    } catch (e) {
      return NotificationSound.gentleChime; // Fallback to default
    }
  }

  /// Set the notification sound preference
  Future<void> setSelectedSound(NotificationSound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundPreferenceKey, sound.fileName);
  }

  /// Get all available sounds
  List<NotificationSound> getAvailableSounds() {
    return NotificationSound.values;
  }

  /// Preview a notification sound
  Future<void> previewSound(NotificationSound sound) async {
    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();

      if (kIsWeb) {
        debugPrint('Sound preview not supported on web');
        return;
      }

      // Try to play from assets
      final assetPath = 'sounds/${sound.fileName}.mp3';
      debugPrint('Attempting to preview sound: $assetPath');

      try {
        await _audioPlayer.play(AssetSource(assetPath));
        debugPrint('✅ Sound preview playing: ${sound.displayName}');
      } catch (assetError) {
        // MP3 files not added yet - play system sound as fallback
        debugPrint('⚠️ MP3 file not found, playing system sound as fallback');
        debugPrint('Add MP3 files to assets/sounds/ for custom sounds');

        // Play system click sound as feedback
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      debugPrint('Error previewing sound: $e');
      // Last resort - try system sound
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // Silently fail
      }
    }
  }

  /// Stop any currently playing preview
  Future<void> stopPreview() async {
    await _audioPlayer.stop();
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Provider for the sound service
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// Provider for the currently selected notification sound
final selectedSoundProvider = FutureProvider<NotificationSound>((ref) async {
  final soundService = ref.watch(soundServiceProvider);
  return await soundService.getSelectedSound();
});

/// Provider to update the selected sound
final soundSelectionProvider =
    StateNotifierProvider<SoundSelectionNotifier, NotificationSound>((ref) {
  return SoundSelectionNotifier(ref);
});

/// Notifier to manage sound selection state
class SoundSelectionNotifier extends StateNotifier<NotificationSound> {
  final Ref ref;

  SoundSelectionNotifier(this.ref) : super(NotificationSound.gentleChime) {
    _loadSound();
  }

  Future<void> _loadSound() async {
    final soundService = ref.read(soundServiceProvider);
    state = await soundService.getSelectedSound();
  }

  Future<void> setSound(NotificationSound sound) async {
    final soundService = ref.read(soundServiceProvider);
    await soundService.setSelectedSound(sound);
    state = sound;
  }
}
