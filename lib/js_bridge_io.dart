import 'package:flutter/services.dart';

double cihazPusulaAcisiOkuBridge() => -1;

bool pusulaSensorIzniIsteBridge() => false;

void cihazTitretBridge(int sureMs) {
  if (sureMs >= 60) {
    HapticFeedback.heavyImpact();
  } else {
    HapticFeedback.lightImpact();
  }
}

void bildirimSesiCalBridge(String baslik, String icerik) {
  SystemSound.play(SystemSoundType.alert);
}

extension DartFuncToJsIoExt<T extends Function> on T {
  T get toJS => this;
}
