import 'dart:convert';
import 'dart:io';

// Native Android / iOS (dart:io) için Web API Uyumluluk Katmanı (Kalıcı Disk Hafızalı)
class Event {}

class _IoLocalStorage {
  final Map<String, String> _cache = {};
  bool _loaded = false;

  File get _file => File('${Directory.systemTemp.path}/vakti_huzur_local_storage.json');

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    try {
      if (_file.existsSync()) {
        final raw = _file.readAsStringSync();
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((k, v) => _cache[k] = v.toString());
      }
    } catch (_) {}
  }

  String? getItem(String key) {
    _ensureLoaded();
    return _cache[key];
  }

  void setItem(String key, String value) {
    _ensureLoaded();
    _cache[key] = value;
    try {
      _file.writeAsStringSync(jsonEncode(_cache));
    } catch (_) {}
  }
}

class SpeechSynthesisUtterance {
  final String text;
  String lang = 'ar-SA';
  double rate = 0.85;
  double pitch = 1.0;
  dynamic onend;
  dynamic onerror;

  SpeechSynthesisUtterance(this.text);
}

class _IoSpeechSynthesis {
  void cancel() {}
  void speak(SpeechSynthesisUtterance utterance) {
    Future.delayed(const Duration(seconds: 2), () {
      if (utterance.onend is void Function(Event)) {
        (utterance.onend as void Function(Event))(Event());
      }
    });
  }
}

class GeolocationCoordinates {
  final double latitude;
  final double longitude;
  const GeolocationCoordinates({this.latitude = 41.0082, this.longitude = 28.9784});
}

class GeolocationPosition {
  final GeolocationCoordinates coords;
  const GeolocationPosition({this.coords = const GeolocationCoordinates()});
}

class GeolocationPositionError {}

class PositionOptions {
  final bool enableHighAccuracy;
  final int timeout;
  final int maximumAge;
  const PositionOptions({
    this.enableHighAccuracy = true,
    this.timeout = 9000,
    this.maximumAge = 60000,
  });
}

class _IoGeolocation {
  void getCurrentPosition(
    dynamic successCallback, [
    dynamic errorCallback,
    PositionOptions? options,
  ]) {
    if (errorCallback is Function) {
      errorCallback(GeolocationPositionError());
    }
  }
}

class _IoNavigator {
  final _IoGeolocation geolocation = _IoGeolocation();
}

class _IoWindow {
  final _IoLocalStorage localStorage = _IoLocalStorage();
  final _IoSpeechSynthesis speechSynthesis = _IoSpeechSynthesis();
  final _IoNavigator navigator = _IoNavigator();

  void open(String url, String target) {}
}

class HTMLAnchorElement {
  String href = '';
  String download = '';
  void click() {}
}

class _IoDocument {
  Object createElement(String tagName) => HTMLAnchorElement();
}

class HTMLAudioElement {
  String preload = 'auto';
  String src = '';
  double currentTime = 0.0;
  dynamic onended;
  dynamic onerror;

  Future<void> play() async {}
  void pause() {}
}

final _IoWindow window = _IoWindow();
final _IoDocument document = _IoDocument();
