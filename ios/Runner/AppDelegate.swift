import Flutter
import UIKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate, FlutterStreamHandler {
  private var locationManager: CLLocationManager?
  private var compassEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "VaktiHuzurCompassPlugin") {
      let channel = FlutterEventChannel(
        name: "com.vaktihuzur.app/compass_stream",
        binaryMessenger: registrar.messenger()
      )
      channel.setStreamHandler(self)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.compassEventSink = events
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      locationManager?.headingFilter = 0.5
    }
    locationManager?.requestWhenInUseAuthorization()
    if CLLocationManager.headingAvailable() {
      locationManager?.startUpdatingHeading()
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingHeading()
    compassEventSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard let sink = compassEventSink else { return }
    let hasTrueHeading = newHeading.trueHeading >= 0
    let headingDeg = hasTrueHeading ? newHeading.trueHeading : newHeading.magneticHeading
    guard headingDeg >= 0 else { return }

    let mx = newHeading.x
    let my = newHeading.y
    let mz = newHeading.z
    let strength = sqrt(mx * mx + my * my + mz * mz)
    let needsCalib = newHeading.headingAccuracy < 0 || newHeading.headingAccuracy > 35

    let payload: [String: Any] = [
      "heading": headingDeg,
      "isTrueNorth": hasTrueHeading,
      "magneticStrength": strength > 0 ? strength : 46.5,
      "needsCalibration": needsCalib,
      "pitch": 0.0,
      "roll": 0.0
    ]
    sink(payload)
  }

  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
}
