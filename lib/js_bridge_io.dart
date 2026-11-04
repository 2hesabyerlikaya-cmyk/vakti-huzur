import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ============================================================================
// GERÇEK MOBİL DONANIM PUSULASI (SENSOR FUSION: ROTATION_VECTOR / CLHeading
// + TILT-COMPENSATED MAGNETOMETER + ACCELEROMETER) VE EZAN / BİLDİRİM SESİ
// ============================================================================

const EventChannel _nativeCompassChannel =
    EventChannel('com.vaktihuzur.app/compass_stream');

bool _sensorBaslatildi = false;
bool _nativeHeadingGeldiMi = false;
bool _nativeTrueNorthMu = false;
double _sonCihazPusulaDerece = -1.0;
double _sinSmooth = 0.0;
double _cosSmooth = 1.0;
bool _ilkOkumaYapildi = false;
double _ax = 0.0, _ay = 0.0, _az = 9.8;
double _mx = 0.0, _my = 25.0, _mz = -40.0;
bool _magIlkOkuma = false;
double _sonManyetikAlanMicroTesla = 46.5;
bool _sonKalibrasyonGerekli = false;
double _sonPitchDerece = 0.0;
double _sonRollDerece = 0.0;

StreamSubscription<dynamic>? _nativeCompassSub;
StreamSubscription<AccelerometerEvent>? _accelSub;
StreamSubscription<MagnetometerEvent>? _magSub;
AudioPlayer? _bildirimPlayer;

void pusulaSensorleriniKapat() {
  _nativeCompassSub?.cancel();
  _accelSub?.cancel();
  _magSub?.cancel();
  _sensorBaslatildi = false;
  _nativeHeadingGeldiMi = false;
}

void _aciGuncelleSmooth(double yeniDerece, {double alpha = 0.24}) {
  final normDeg = (yeniDerece % 360.0 + 360.0) % 360.0;
  final rad = normDeg * (math.pi / 180.0);
  if (!_ilkOkumaYapildi) {
    _sinSmooth = math.sin(rad);
    _cosSmooth = math.cos(rad);
    _ilkOkumaYapildi = true;
  } else {
    _sinSmooth = _sinSmooth + alpha * (math.sin(rad) - _sinSmooth);
    _cosSmooth = _cosSmooth + alpha * (math.cos(rad) - _cosSmooth);
  }
  _sonCihazPusulaDerece =
      (math.atan2(_sinSmooth, _cosSmooth) * (180.0 / math.pi) + 360.0) % 360.0;
}

void _sensorleriBaslat() {
  if (_sensorBaslatildi) return;
  _sensorBaslatildi = true;

  // 1. Öncelik: Native Android SensorManager (TYPE_ROTATION_VECTOR + getOrientation)
  // ve iOS CoreLocation (CLHeading trueHeading/magneticHeading) akışı
  try {
    _nativeCompassSub = _nativeCompassChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final h = (event['heading'] as num?)?.toDouble();
          if (h != null && !h.isNaN && h >= 0) {
            _nativeHeadingGeldiMi = true;
            _nativeTrueNorthMu = event['isTrueNorth'] == true;
            _aciGuncelleSmooth(h, alpha: 0.28);
          }
          final mag = (event['magneticStrength'] as num?)?.toDouble();
          if (mag != null && mag > 0 && !mag.isNaN) {
            _sonManyetikAlanMicroTesla = mag;
          }
          if (event.containsKey('needsCalibration')) {
            _sonKalibrasyonGerekli = event['needsCalibration'] == true;
          }
          final p = (event['pitch'] as num?)?.toDouble();
          final r = (event['roll'] as num?)?.toDouble();
          if (p != null && !p.isNaN) _sonPitchDerece = p;
          if (r != null && !r.isNaN) _sonRollDerece = r;
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  } catch (_) {}

  // 2. Yedek & Eğim Hesaplayıcı: sensors_plus (Accelerometer + Magnetometer)
  // Doğru sağ-el kuralı (East = M × G, North = G × East) ile tilt-compensated azimut
  try {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (AccelerometerEvent e) {
        const double alphaA = 0.18;
        _ax = _ax + alphaA * (e.x - _ax);
        _ay = _ay + alphaA * (e.y - _ay);
        _az = _az + alphaA * (e.z - _az);

        final normG = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
        if (normG > 0.5) {
          _sonPitchDerece = math.asin((_ay / normG).clamp(-1.0, 1.0)) * (180.0 / math.pi);
          _sonRollDerece = math.atan2(-_ax, _az) * (180.0 / math.pi);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _magSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (MagnetometerEvent m) {
        const double alphaM = 0.22;
        if (!_magIlkOkuma) {
          _mx = m.x;
          _my = m.y;
          _mz = m.z;
          _magIlkOkuma = true;
        } else {
          _mx = _mx + alphaM * (m.x - _mx);
          _my = _my + alphaM * (m.y - _my);
          _mz = _mz + alphaM * (m.z - _mz);
        }

        final fieldNorm = math.sqrt(_mx * _mx + _my * _my + _mz * _mz);
        if (!fieldNorm.isNaN && !fieldNorm.isInfinite && fieldNorm > 0) {
          _sonManyetikAlanMicroTesla = fieldNorm;
        }

        // Eğer Native RotationVector/CLHeading aktifse açıyı ezme, sadece yedek olarak çalış
        if (_nativeHeadingGeldiMi) return;

        // Android SensorManager.getRotationMatrix + getOrientation ile birebir aynı matris matematiği:
        // H = E = M × G (Doğu birim vektörü)
        // M_north = G × H (Kuzey birim vektörü)
        // Azimut (cihazın üst kısmının +Y ekseninin Kuzey ile yaptığı saat yönü açısı) = atan2(Hx, My_north)
        double ex = _my * _az - _mz * _ay;
        double ey = _mz * _ax - _mx * _az;
        double ez = _mx * _ay - _my * _ax;
        final normE = math.sqrt(ex * ex + ey * ey + ez * ez);
        final normG = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);

        double headingDeg;
        if (normG > 0.5 && normE > 0.05) {
          ex /= normE;
          ey /= normE;
          ez /= normE;
          final gx = _ax / normG;
          final gy = _ay / normG;
          final gz = _az / normG;
          // Kuzey vektörü N = G × E -> Ny = gz * ex - gx * ez
          final ny = gz * ex - gx * ez;
          // DİKKAT: atan2(ex, ny) — ex (Doğu bileşeni), ny (Kuzey bileşeni)!
          headingDeg = math.atan2(ex, ny) * (180.0 / math.pi);
          if (gy.isNaN || headingDeg.isNaN) {
            headingDeg = math.atan2(-_mx, _my) * (180.0 / math.pi);
          }
        } else {
          headingDeg = math.atan2(-_mx, _my) * (180.0 / math.pi);
        }

        _aciGuncelleSmooth(headingDeg, alpha: 0.22);
      },
      onError: (_) {},
      cancelOnError: false,
    );
  } catch (_) {}
}

double cihazPusulaAcisiOkuBridge() {
  _sensorleriBaslat();
  return _sonCihazPusulaDerece;
}

bool pusulaNativeTrueNorthMuBridge() {
  return _nativeHeadingGeldiMi && _nativeTrueNorthMu;
}

double pusulaManyetikAlanSiddetiOkuBridge() {
  _sensorleriBaslat();
  return _sonManyetikAlanMicroTesla;
}

bool pusulaKalibrasyonGerekliMiBridge() {
  return _sonKalibrasyonGerekli ||
      _sonManyetikAlanMicroTesla < 22.0 ||
      _sonManyetikAlanMicroTesla > 68.0;
}

bool pusulaMasaustuModundaMiBridge() {
  // Cihaz masaya düz koyulduğunda eğim (pitch ve roll) ±20° altındadır
  return _sonPitchDerece.abs() < 22.0 && _sonRollDerece.abs() < 22.0;
}

double pusulaEgimPitchOkuBridge() => _sonPitchDerece;

double pusulaEgimRollOkuBridge() => _sonRollDerece;

bool pusulaSensorIzniIsteBridge() {
  _sensorleriBaslat();
  return true;
}

void cihazTitretBridge(int sureMs) {
  if (sureMs >= 60) {
    HapticFeedback.heavyImpact();
  } else {
    HapticFeedback.lightImpact();
  }
}

/// Bildirim sesi / Ezan sesi önizleme ve çalma:
/// sesModu: 'ezan' (Tam Ezan Sesi), 'kisa' (Kısa Uyarı Sesi), 'sessiz' (Sessiz)
Future<void> bildirimSesiCalBridge(
  String baslik,
  String icerik, {
  String sesModu = 'ezan',
}) async {
  if (sesModu == 'sessiz') return;
  try {
    _bildirimPlayer ??= AudioPlayer();
    await _bildirimPlayer!.stop();
    if (sesModu == 'ezan') {
      await _bildirimPlayer!.play(AssetSource('audio/adhan.mp3'));
    } else {
      await _bildirimPlayer!.play(AssetSource('audio/adhan_short.wav'));
    }
  } catch (_) {
    SystemSound.play(SystemSoundType.alert);
  }
}

Future<void> bildirimSesiDurdurBridge() async {
  try {
    await _bildirimPlayer?.stop();
  } catch (_) {}
}

AudioPlayer? _tesbihPlayer;
Uint8List? _tesbihWavBytes;

Uint8List _olusturTokTesbihTikWav() {
  if (_tesbihWavBytes != null) return _tesbihWavBytes!;
  const int sampleRate = 22050;
  const double durationSec = 0.04;
  final int numSamples = (sampleRate * durationSec).toInt();
  final int dataSize = numSamples * 2;
  final ByteData buffer = ByteData(44 + dataSize);

  const List<int> riff = [0x52, 0x49, 0x46, 0x46];
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(i, riff[i]);
  }
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  const List<int> wave = [0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20];
  for (int i = 0; i < 8; i++) {
    buffer.setUint8(8 + i, wave[i]);
  }
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  const List<int> dataH = [0x64, 0x61, 0x74, 0x61];
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(36 + i, dataH[i]);
  }
  buffer.setUint32(40, dataSize, Endian.little);

  for (int i = 0; i < numSamples; i++) {
    final double t = i / sampleRate;
    final double decay = math.exp(-t * 110.0);
    final double tone = math.sin(2.0 * math.pi * 560.0 * t) * 0.75 +
        math.sin(2.0 * math.pi * 1200.0 * t) * 0.25;
    final double sample = (tone * decay).clamp(-1.0, 1.0);
    final int pcm = (sample * 32767).toInt();
    buffer.setInt16(44 + i * 2, pcm, Endian.little);
  }

  _tesbihWavBytes = buffer.buffer.asUint8List();
  return _tesbihWavBytes!;
}

void tesbihSesiCalBridge() {
  try {
    SystemSound.play(SystemSoundType.click);
    _tesbihPlayer ??= AudioPlayer();
    final bytes = _olusturTokTesbihTikWav();
    _tesbihPlayer!.stop();
    _tesbihPlayer!.play(BytesSource(bytes, mimeType: 'audio/wav'), volume: 0.85);
  } catch (_) {
    SystemSound.play(SystemSoundType.click);
  }
}

extension DartFuncToJsIoExt<T extends Function> on T {
  T get toJS => this;
}
