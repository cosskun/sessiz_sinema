import 'package:flutter/services.dart';

/// Audio & Haptic feedback service.
/// Provides zero-latency feedback using Flutter's native SystemSound and HapticFeedback APIs.
class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  bool isSoundEnabled = true;
  bool isHapticEnabled = true;

  /// Toggles global sound effects state
  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    if (isSoundEnabled) {
      playSuccess();
    }
  }

  /// Toggles global haptic feedback state
  void toggleHaptic() {
    isHapticEnabled = !isHapticEnabled;
    if (isHapticEnabled) {
      playSuccess();
    }
  }

  /// Timer countdown tick in the last 10 seconds
  void playTick() {
    try {
      if (isSoundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      if (isHapticEnabled) {
        HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Gracefully handled for headless/test environments
    }
  }

  /// Correct guess / scoring point
  void playSuccess() {
    try {
      if (isSoundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      if (isHapticEnabled) {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {}
  }

  /// Turn time out / failure alert
  void playTimeOut() {
    try {
      if (isSoundEnabled) {
        SystemSound.play(SystemSoundType.alert);
      }
      if (isHapticEnabled) {
        HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  /// Pass/skip action feedback
  void playPass() {
    try {
      if (isSoundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      if (isHapticEnabled) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  /// Game won celebration feedback
  void playCelebration() {
    try {
      if (isSoundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      if (isHapticEnabled) {
        HapticFeedback.vibrate();
      }
    } catch (_) {}
  }
}
