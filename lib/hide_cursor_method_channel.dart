import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hide_cursor_platform_interface.dart';

/// An implementation of [HideCursorPlatform] that uses method channels.
class MethodChannelHideCursor extends HideCursorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hide_cursor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  
  @override
  Future<bool> hideCursor() async {
    final result = await methodChannel.invokeMethod<bool>('hideCursor');
    return result ?? false;
  }
  
  @override
  Future<bool> showCursor() async {
    final result = await methodChannel.invokeMethod<bool>('showCursor');
    return result ?? false;
  }
}
