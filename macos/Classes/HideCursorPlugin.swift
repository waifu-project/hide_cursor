import Cocoa
import FlutterMacOS

public class HideCursorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hide_cursor", binaryMessenger: registrar.messenger)
    let instance = HideCursorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "hideCursor":
      NSCursor.hide()
      result(true)
    case "showCursor":
      NSCursor.unhide()
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}