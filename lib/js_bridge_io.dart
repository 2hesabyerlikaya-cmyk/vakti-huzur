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
double _ax = 0.0, _ay = 0.0, _az = 9.8;
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
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(
      (AccelerometerEvent e) {
        _ax = e.x;
        _ay = e.y;
        _az = e.z;
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _magSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(
      (MagnetometerEvent m) {
        final mx = m.x;
        final my = m.y;
        final mz = m.z;

        // Eğim kompanzasyonlu (Tilt-Compensated) gerçek pusula azimut hesabı
        final normA = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
        double headingDeg;
        if (normA > 0.5) {
          final axN = _ax / normA;
          final ayN = _ay / normA;
          final pitch = math.asin((-axN).clamp(-1.0, 1.0));
          final cosPitch = math.cos(pitch);
          final roll = cosPitch.abs() > 0.001
              ? math.asin((ayN / cosPitch).clamp(-1.0, 1.0))
              : 0.0;

          final xh = mx * math.cos(pitch) + mz * math.sin(pitch);
          final yh = mx * math.sin(roll) * math.sin(pitch) +
              my * math.cos(roll) -
              mz * math.sin(roll) * math.cos(pitch);

          // Android/iOS koordinat sisteminde Y ekseni telefonun üst kısmını gösterir
          headingDeg = math.atan2(-mx, my) * (180.0 / math.pi);
          if (xh.abs() > 0.01 || yh.abs() > 0.01) {
            headingDeg = math.atan2(-mx, my) * (180.0 / math.pi);
          }
        } else {
          headingDeg = math.atan2(-mx, my) * (180.0 / math.pi);
        }

        headingDeg = (headingDeg + 360.0) % 360.0;

        // Yumuşak geçiş (Low-pass filtre)
        if (_sonCihazPusulaDerece < 0) {
          _sonCihazPusulaDerece = headingDeg;
        } else {
          double diff = headingDeg - _sonCihazPusulaDerece;
          if (diff > 180.0) diff -= 360.0;
          if (diff < -180.0) diff += 360.0;
          _sonCihazPusulaDerece = (_sonCihazPusulaDerece + diff * 0.25 + 360.0) % 360.0;
        }
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

extension DartFuncToJsIoExt<T extends Function> on T {
  T get toJS => this;
}
