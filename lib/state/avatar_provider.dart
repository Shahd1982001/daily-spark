import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One device-local avatar for the current preview user. No cloud upload.
class AvatarController extends Notifier<Uint8List?> {
  static const storageKey = 'ds_profile_avatar_v1';
  static const maxBytes = 750 * 1024;
  int _revision = 0;

  @override
  Uint8List? build() {
    Future.microtask(_load);
    return null;
  }

  Future<void> _load() async {
    final revision = _revision;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(storageKey);
      if (encoded == null || encoded.length > maxBytes * 2) return;
      final bytes = base64Decode(encoded);
      if (bytes.isEmpty || bytes.length > maxBytes || revision != _revision) return;
      state = bytes;
    } catch (_) {
      // Bad persisted data should show the fallback instead of crashing.
    }
  }

  /// Saves only a decodable, size-limited image. Returns false on validation
  /// or storage failure and leaves the existing image untouched.
  Future<bool> save(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > maxBytes) return false;
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1, targetHeight: 1);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      codec.dispose();
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(storageKey, base64Encode(bytes))) return false;
      _revision++;
      state = Uint8List.fromList(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remove() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.remove(storageKey)) return false;
      _revision++;
      state = null;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final avatarProvider = NotifierProvider<AvatarController, Uint8List?>(AvatarController.new);
