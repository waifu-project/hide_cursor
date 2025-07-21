import 'package:flutter_test/flutter_test.dart';
import 'package:hide_cursor/hide_cursor.dart';
import 'package:hide_cursor/hide_cursor_platform_interface.dart';
import 'package:hide_cursor/hide_cursor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHideCursorPlatform
    with MockPlatformInterfaceMixin
    implements HideCursorPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> hideCursor() => Future.value(true);

  @override
  Future<bool> showCursor() => Future.value(true);
}

void main() {
  final HideCursorPlatform initialPlatform = HideCursorPlatform.instance;

  test('$MethodChannelHideCursor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHideCursor>());
  });

  test('getPlatformVersion', () async {
    HideCursor hideCursorPlugin = HideCursor();
    MockHideCursorPlatform fakePlatform = MockHideCursorPlatform();
    HideCursorPlatform.instance = fakePlatform;

    expect(await hideCursorPlugin.getPlatformVersion(), '42');
  });

  test('hideCursor', () async {
    HideCursor hideCursorPlugin = HideCursor();
    MockHideCursorPlatform fakePlatform = MockHideCursorPlatform();
    HideCursorPlatform.instance = fakePlatform;

    expect(await hideCursorPlugin.hideCursor(), true);
  });

  test('showCursor', () async {
    HideCursor hideCursorPlugin = HideCursor();
    MockHideCursorPlatform fakePlatform = MockHideCursorPlatform();
    HideCursorPlatform.instance = fakePlatform;

    expect(await hideCursorPlugin.showCursor(), true);
  });
}
