import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ============================================================================
// GERÇEK MOBİL DONANIM PUSULASI (MANYETOMETRE + İVMEÖLÇER) VE BİLDİRİM SESİ
// ============================================================================

bool _sensorBaslatildi = false;
double _sonCihazPusulaDerece = -1.0;
double _sinSmooth = 0.0;
double _cosSmooth = 1.0;
bool _ilkOkumaYapildi = false;
double _ax = 0.0, _ay = 0.0, _az = 9.8;
double _mx = 0.0, _my = 25.0, _mz = -40.0;
bool _magIlkOkuma = false;
double _sonManyetikAlanMicroTesla = 46.5;
StreamSubscription<AccelerometerEvent>? _accelSub;
StreamSubscription<MagnetometerEvent>? _magSub;
AudioPlayer? _bildirimPlayer;

void pusulaSensorleriniKapat() {
  _accelSub?.cancel();
  _magSub?.cancel();
  _sensorBaslatildi = false;
}

void _sensorleriBaslat() {
  if (_sensorBaslatildi) return;
  _sensorBaslatildi = true;

  try {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (AccelerometerEvent e) {
        // 1. Aşama Low-Pass Filtre: İvmeölçer (yerçekimi vektörü) titreşim sönümleme
        const double alphaA = 0.16;
        _ax = _ax + alphaA * (e.x - _ax);
        _ay = _ay + alphaA * (e.y - _ay);
        _az = _az + alphaA * (e.z - _az);
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _magSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (MagnetometerEvent m) {
        // 2. Aşama Low-Pass Filtre: Ham manyetometre gürültü ve sıçrama sönümleme
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

        // Manyetik alan şiddeti (µT) — Kalibrasyon doğruluğu kontrolü için
        final fieldNorm = math.sqrt(_mx * _mx + _my * _my + _mz * _mz);
        if (!fieldNorm.isNaN && !fieldNorm.isInfinite) {
          _sonManyetikAlanMicroTesla = fieldNorm;
        }

        // Eğim kompanzasyonlu (Tilt-Compensated) gerçek manyetik azimut:
        // H = M x A (Doğu vektörü), N = A x H (Kuzey vektörü)
        double headingDeg;
        final normA = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
        double hx = _my * _az - _mz * _ay;
        double hy = _mz * _ax - _mx * _az;
        double hz = _mx * _ay - _my * _ax;
        final normH = math.sqrt(hx * hx + hy * hy + hz * hz);

        if (normA > 0.5 && normH > 0.05) {
          hx /= normH;
          hy /= normH;
          hz /= normH;
          final axN = _ax / normA;
          final ayN = _ay / normA;
          final azN = _az / normA;
          final myN = azN * hx - axN * hz;
          headingDeg = math.atan2(hy, myN) * (180.0 / math.pi);
          if (ayN.isNaN || headingDeg.isNaN) {
            headingDeg = math.atan2(-_mx, _my) * (180.0 / math.pi);
          }
        } else {
          // Cihaz yatay düzlemdeyken doğrudan azimut
          headingDeg = math.atan2(-_mx, _my) * (180.0 / math.pi);
        }

        headingDeg = (headingDeg + 360.0) % 360.0;
        final rad = headingDeg * (math.pi / 180.0);

        // 3. Aşama Dairesel Trigonometrik Low-Pass Filtre (0°-360° geçişinde takılmayı %100 önler)
        const double alphaHeading = 0.20;
        if (!_ilkOkumaYapildi) {
          _sinSmooth = math.sin(rad);
          _cosSmooth = math.cos(rad);
          _ilkOkumaYapildi = true;
        } else {
          _sinSmooth = _sinSmooth + alphaHeading * (math.sin(rad) - _sinSmooth);
          _cosSmooth = _cosSmooth + alphaHeading * (math.cos(rad) - _cosSmooth);
        }

        _sonCihazPusulaDerece =
            (math.atan2(_sinSmooth, _cosSmooth) * (180.0 / math.pi) + 360.0) % 360.0;
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

double pusulaManyetikAlanSiddetiOkuBridge() {
  _sensorleriBaslat();
  return _sonManyetikAlanMicroTesla;
}

bool pusulaKalibrasyonGerekliMiBridge() {
  // Dünya manyetik alanı normalde 25 µT - 65 µT arasındadır.
  // Bunun dışındaysa yakınlarda mıknatıs/metal kılıf vardır veya 8 çizerek kalibrasyon gerekir.
  return _sonManyetikAlanMicroTesla < 22.0 || _sonManyetikAlanMicroTesla > 68.0;
}

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

/// Çevrimdışı çalışan huzurlu harmonik bildirim sesi (528Hz + 660Hz + 792Hz WAV Sentezleyici)
Uint8List _olusturHuzurBildirimWav() {
  const int sampleRate = 44100;
  const double durationSec = 1.35;
  final int numSamples = (sampleRate * durationSec).toInt();
  final int dataSize = numSamples * 2; // 16-bit mono
  final ByteData buffer = ByteData(44 + dataSize);

  // RIFF Header
  const List<int> riff = [0x52, 0x49, 0x46, 0x46]; // "RIFF"
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(i, riff[i]);
  }
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  const List<int> waveFmt = [
    0x57, 0x41, 0x56, 0x45, // "WAVE"
    0x66, 0x6D, 0x74, 0x20, // "fmt "
  ];
  for (int i = 0; i < 8; i++) {
    buffer.setUint8(8 + i, waveFmt[i]);
  }
  buffer.setUint32(16, 16, Endian.little); // PCM chunk size
  buffer.setUint16(20, 1, Endian.little); // PCM format
  buffer.setUint16(22, 1, Endian.little); // 1 channel (mono)
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  buffer.setUint16(32, 2, Endian.little); // block align
  buffer.setUint16(34, 16, Endian.little); // bits per sample

  const List<int> dataHdr = [0x64, 0x61, 0x74, 0x61]; // "data"
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(36 + i, dataHdr[i]);
  }
  buffer.setUint32(40, dataSize, Endian.little);

  const List<double> freqs = [528.0, 660.0, 792.0];
  const List<double> starts = [0.0, 0.16, 0.32];

  for (int i = 0; i < numSamples; i++) {
    final double t = i / sampleRate;
    double sample = 0.0;
    for (int n = 0; n < freqs.length; n++) {
      final double dt = t - starts[n];
      if (dt >= 0) {
        final double attack = (dt / 0.03).clamp(0.0, 1.0);
        final double decay = math.exp(-dt * 3.8);
        sample += math.sin(2.0 * math.pi * freqs[n] * dt) * attack * decay * 0.28;
      }
    }
    final int pcm = (sample.clamp(-1.0, 1.0) * 32767).toInt();
    buffer.setInt16(44 + i * 2, pcm, Endian.little);
  }

  return buffer.buffer.asUint8List();
}

Future<void> bildirimSesiCalBridge(String baslik, String icerik) async {
  try {
    _bildirimPlayer ??= AudioPlayer();
    final wavBytes = _olusturHuzurBildirimWav();
    await _bildirimPlayer!.stop();
    await _bildirimPlayer!.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
  } catch (_) {
    SystemSound.play(SystemSoundType.alert);
  }
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

  // RIFF Header
  const List<int> riff = [0x52, 0x49, 0x46, 0x46]; // "RIFF"
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(i, riff[i]);
  }
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  const List<int> wave = [0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20];
  for (int i = 0; i < 8; i++) {
    buffer.setUint8(8 + i, wave[i]);
  }
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little); // PCM
  buffer.setUint16(22, 1, Endian.little); // Mono
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  const List<int> dataH = [0x64, 0x61, 0x74, 0x61]; // "data"
  for (int i = 0; i < 4; i++) {
    buffer.setUint8(36 + i, dataH[i]);
  }
  buffer.setUint32(40, dataSize, Endian.little);

  // Tok ahşap tesbih tıkı darbesi
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
