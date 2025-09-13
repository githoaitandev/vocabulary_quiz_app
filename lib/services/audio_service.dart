import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service quản lý audio feedback cho quiz interactions
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _audioPlayer;
  bool _isEnabled = true;
  bool _isInitialized = false;
  bool _useCustomSounds = false; // Toggle between system and custom sounds

  /// Initialize audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _audioPlayer = AudioPlayer();
      _isInitialized = true;
    } catch (e) {
      // Silently fail audio initialization
      _isInitialized = false;
    }
  }

  /// Play correct answer sound (quiz context - uses custom if available)
  Future<void> playCorrectSound() async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      if (_useCustomSounds) {
        // Play custom sound file for quiz answers
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } else {
        // Use system sounds
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // Fallback to system sound if custom sound fails
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play incorrect answer sound (quiz context - uses custom if available)
  Future<void> playIncorrectSound() async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      if (_useCustomSounds) {
        // Play custom buzzer/error sound for quiz answers
        await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } else {
        // Use system alert sound
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      // Fallback to system sound if custom sound fails
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play system click sound only (for navigation, import, etc.)
  Future<void> playSystemClickSound() async {
    if (!_isEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail
    }
  }

  /// Play system success sound (for successful operations like import)
  Future<void> playSystemSuccessSound() async {
    if (!_isEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail
    }
  }

  /// Play quiz completion sound
  Future<void> playCompletionSound() async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      if (_useCustomSounds) {
        // Play custom celebration sound
        await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
      } else {
        // Use system sounds sequence
        await SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 100));
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // Fallback to system sound sequence
      try {
        await SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 100));
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play button click sound (always system sound)
  Future<void> playClickSound() async {
    if (!_isEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail
    }
  }

  /// Enable/disable audio feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if audio is enabled
  bool get isEnabled => _isEnabled;

  /// Enable/disable custom sounds (vs system sounds)
  void setUseCustomSounds(bool useCustom) {
    _useCustomSounds = useCustom;
  }

  /// Check if using custom sounds
  bool get useCustomSounds => _useCustomSounds;

  /// Dispose audio player
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _audioPlayer.dispose();
        _isInitialized = false;
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play custom sound from assets (for future enhancement)
  Future<void> playCustomSound(String assetPath) async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Silently fail
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      // Silently fail
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Silently fail
    }
  }
}

/// Audio feedback types
enum AudioFeedbackType {
  correct,        // Quiz answer correct (custom sound if available)
  incorrect,      // Quiz answer incorrect (custom sound if available) 
  completion,     // Quiz completion
  click,          // Button click (always system)
  systemClick,    // System click for navigation/import
  systemSuccess,  // System success for operations
}

/// Extension để easily play different feedback types
extension AudioFeedbackExtension on AudioService {
  Future<void> playFeedback(AudioFeedbackType type) async {
    switch (type) {
      case AudioFeedbackType.correct:
        await playCorrectSound();
        break;
      case AudioFeedbackType.incorrect:
        await playIncorrectSound();
        break;
      case AudioFeedbackType.completion:
        await playCompletionSound();
        break;
      case AudioFeedbackType.click:
        await playClickSound();
        break;
      case AudioFeedbackType.systemClick:
        await playSystemClickSound();
        break;
      case AudioFeedbackType.systemSuccess:
        await playSystemSuccessSound();
        break;
    }
  }
}