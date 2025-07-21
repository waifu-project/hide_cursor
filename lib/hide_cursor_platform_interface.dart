import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hide_cursor_method_channel.dart';

abstract class HideCursorPlatform extends PlatformInterface {
  /// Constructs a HideCursorPlatform.
  HideCursorPlatform() : super(token: _token);

  static final Object _token = Object();

  static HideCursorPlatform _instance = MethodChannelHideCursor();

  /// The default instance of [HideCursorPlatform] to use.
  ///
  /// Defaults to [MethodChannelHideCursor].
  static HideCursorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HideCursorPlatform] when
  /// they register themselves.
  static set instance(HideCursorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  /// Hides the cursor at system level
  Future<bool> hideCursor() {
    throw UnimplementedError('hideCursor() has not been implemented.');
  }
  
  /// Shows the cursor at system level
  Future<bool> showCursor() {
    throw UnimplementedError('showCursor() has not been implemented.');
  }
}
