import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart' as geo;

// Native Android / iOS (dart:io) için Gerçek Ses (AudioPlayers), Gerçek GPS (Geolocator)
// ve Kalıcı Disk Hafızası (LocalStorage) Katmanı

class Event {}

class IoLocalStorage {
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

class IoSpeechSynthesis {
  AudioPlayer? _ttsPlayer;
  StreamSubscription<void>? _completeSub;

  void _ensurePlayer() {
    if (_ttsPlayer != null) return;
    _ttsPlayer = AudioPlayer();
    _ttsPlayer!.setReleaseMode(ReleaseMode.stop);
  }

  void cancel() {
    try {
      _completeSub?.cancel();
      _ttsPlayer?.stop();
    } catch (_) {}
  }

  Future<void> speak(SpeechSynthesisUtterance utterance) async {
    try {
      cancel();
      _ensurePlayer();
      final rawText = utterance.text.trim();
      if (rawText.isEmpty) {
        if (utterance.onend is void Function(Event)) {
          (utterance.onend as void Function(Event))(Event());
        }
        return;
      }

      // 180 karakterlik anlamlı parçalara bölerek sırayla Arapça seslendir
      final parcalar = _metniParcala(rawText, maxLen: 180);
      int idx = 0;

      Future<void> sonrakiParcaCal() async {
        if (idx >= parcalar.length) {
          if (utterance.onend is void Function(Event)) {
            (utterance.onend as void Function(Event))(Event());
          }
          return;
        }
        final parca = parcalar[idx++];
        final encoded = Uri.encodeComponent(parca);
        final langCode = utterance.lang.startsWith('ar') ? 'ar' : 'tr';
        final ttsUrl =
            'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=$langCode&q=$encoded';

        await _completeSub?.cancel();
        _completeSub = _ttsPlayer!.onPlayerComplete.listen((_) {
          sonrakiParcaCal();
        });

        await _ttsPlayer!.play(UrlSource(ttsUrl));
      }

      await sonrakiParcaCal();
    } catch (_) {
      if (utterance.onerror is void Function(Event)) {
        (utterance.onerror as void Function(Event))(Event());
      }
    }
  }

  List<String> _metniParcala(String metin, {int maxLen = 180}) {
    if (metin.length <= maxLen) return [metin];
    final kelimeler = metin.split(RegExp(r'\s+'));
    final sonuc = <String>[];
    var aktif = '';
    for (final k in kelimeler) {
      if (aktif.isEmpty) {
        aktif = k;
      } else if (aktif.length + 1 + k.length <= maxLen) {
        aktif = '$aktif $k';
      } else {
        sonuc.add(aktif);
        aktif = k;
      }
    }
    if (aktif.isNotEmpty) sonuc.add(aktif);
    return sonuc;
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

class IoGeolocation {
  Future<void> getCurrentPosition(
    dynamic successCallback, [
    dynamic errorCallback,
    PositionOptions? options,
  ]) async {
    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (errorCallback is void Function(GeolocationPositionError)) {
          errorCallback(GeolocationPositionError());
        }
        return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        if (errorCallback is void Function(GeolocationPositionError)) {
          errorCallback(GeolocationPositionError());
        }
        return;
      }

      final pos = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (successCallback is void Function(GeolocationPosition)) {
        successCallback(
          GeolocationPosition(
            coords: GeolocationCoordinates(
              latitude: pos.latitude,
              longitude: pos.longitude,
            ),
          ),
        );
      }
    } catch (_) {
      if (errorCallback is void Function(GeolocationPositionError)) {
        errorCallback(GeolocationPositionError());
      }
    }
  }
}

class IoNavigator {
  final IoGeolocation geolocation = IoGeolocation();
}

class IoWindow {
  final IoLocalStorage localStorage = IoLocalStorage();
  final IoSpeechSynthesis speechSynthesis = IoSpeechSynthesis();
  final IoNavigator navigator = IoNavigator();

  void open(String url, String target) {}
}

class HTMLAnchorElement {
  String href = '';
  String download = '';
  void click() {}
}

class IoDocument {
  Object createElement(String tagName) => HTMLAnchorElement();
}

class HTMLAudioElement {
  static bool _globalContextInitialized = false;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;

  String preload = 'auto';
  String src = '';
  double currentTime = 0.0;
  dynamic onended;
  dynamic onerror;

  HTMLAudioElement() {
    _initGlobalContext();
    _player.setReleaseMode(ReleaseMode.stop);
    _completeSub = _player.onPlayerComplete.listen((_) {
      _tetikle(onended);
    });
  }

  void _tetikle(dynamic handler) {
    if (handler == null) return;
    try {
      if (handler is Function) {
        try {
          (handler as dynamic)(Event());
        } catch (_) {
          try {
            (handler as dynamic)();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  static void _initGlobalContext() {
    if (_globalContextInitialized) return;
    _globalContextInitialized = true;
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> play() async {
    try {
      if (src.isEmpty) return;
      await _player.stop();
      await _player.play(UrlSource(src));
    } catch (_) {
      _tetikle(onerror);
    }
  }

  void pause() {
    try {
      _player.pause();
    } catch (_) {}
  }

  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
  }
}

final IoWindow window = IoWindow();
final IoDocument document = IoDocument();
