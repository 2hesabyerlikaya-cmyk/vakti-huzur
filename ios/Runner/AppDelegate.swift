import Flutter
import UIKit
import CoreLocation
import UserNotifications
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate, FlutterStreamHandler {
  private var locationManager: CLLocationManager?
  private var compassEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
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

      let mediaChannel = FlutterMethodChannel(
        name: "com.berat.vaktiberaat/native_media",
        binaryMessenger: registrar.messenger()
      )
      mediaChannel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          result(false)
          return
        }
        switch call.method {
        case "saveImageToGallery":
          guard let args = call.arguments as? [String: Any],
                let typedData = args["bytes"] as? FlutterStandardTypedData else {
            result(false)
            return
          }
          self.galeriyeKaydet(data: typedData.data, completion: result)

        case "shareImage":
          guard let args = call.arguments as? [String: Any],
                let typedData = args["bytes"] as? FlutterStandardTypedData else {
            result(false)
            return
          }
          let fileName = (args["fileName"] as? String) ?? "vakti_beraat_story.png"
          let text = (args["text"] as? String) ?? ""
          self.gorselPaylas(data: typedData.data, fileName: fileName, text: text, completion: result)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  private func galeriyeKaydet(data: Data, completion: @escaping FlutterResult) {
    let kaydetIslemi = {
      PHPhotoLibrary.shared().performChanges({
        let req = PHAssetCreationRequest.forAsset()
        req.addResource(with: .photo, data: data, options: nil)
      }) { success, _ in
        DispatchQueue.main.async {
          if success {
            completion(true)
          } else if let img = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            completion(true)
          } else {
            completion(false)
          }
        }
      }
    }

    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        if status == .authorized || status == .limited {
          kaydetIslemi()
        } else {
          DispatchQueue.main.async { completion(false) }
        }
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          kaydetIslemi()
        } else {
          DispatchQueue.main.async { completion(false) }
        }
      }
    }
  }

  private func gorselPaylas(data: Data, fileName: String, text: String, completion: @escaping FlutterResult) {
    DispatchQueue.main.async {
      let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
      try? data.write(to: tempUrl, options: .atomic)

      var items: [Any] = []
      if let img = UIImage(data: data) {
        items.append(img)
      } else {
        items.append(tempUrl)
      }
      if !text.isEmpty {
        items.append(text)
      }

      let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
      guard let rootVC = self.aktifViewController() else {
        completion(false)
        return
      }
      if let pop = activityVC.popoverPresentationController {
        pop.sourceView = rootVC.view
        pop.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
        pop.permittedArrowDirections = []
      }
      rootVC.present(activityVC, animated: true) {
        completion(true)
      }
    }
  }

  private func aktifViewController() -> UIViewController? {
    var root: UIViewController?
    if #available(iOS 13.0, *) {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        ?? scenes.first as? UIWindowScene
      root = windowScene?.windows.first { $0.isKeyWindow }?.rootViewController
        ?? windowScene?.windows.first?.rootViewController
    }
    if root == nil {
      root = UIApplication.shared.keyWindow?.rootViewController
    }
    while let presented = root?.presentedViewController {
      root = presented
    }
    return root
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
    let trueH = newHeading.trueHeading
    let magH = newHeading.magneticHeading
    let heading = trueH >= 0 ? trueH : magH
    let accuracy = newHeading.headingAccuracy

    let magStrength = sqrt(
      newHeading.x * newHeading.x +
      newHeading.y * newHeading.y +
      newHeading.z * newHeading.z
    )
    let needsCal = accuracy < 0 || accuracy > 25

    let payload: [String: Any] = [
      "heading": heading,
      "isTrueNorth": trueH >= 0,
      "magneticStrength": magStrength > 0 ? magStrength : 46.0,
      "needsCalibration": needsCal,
      "pitch": 0.0,
      "roll": 0.0
    ]
    sink(payload)
  }

  func locationManagerShouldDisplayCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
}
