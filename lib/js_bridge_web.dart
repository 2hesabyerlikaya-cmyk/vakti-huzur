import 'dart:js_interop';
export 'dart:js_interop';

@JS('cihazPusulaAcisiOku')
external double _cihazPusulaAcisiOkuJs();

@JS('pusulaSensorIzniIste')
external bool _pusulaSensorIzniIsteJs();

@JS('cihazTitret')
external void _cihazTitretJs(int sureMs);

@JS('bildirimSesiCal')
external void _bildirimSesiCalJs(String baslik, String icerik);

double cihazPusulaAcisiOkuBridge() {
  try {
    return _cihazPusulaAcisiOkuJs();
  } catch (_) {
    return -1;
  }
}

bool pusulaSensorIzniIsteBridge() {
  try {
    return _pusulaSensorIzniIsteJs();
  } catch (_) {
    return false;
  }
}

void cihazTitretBridge(int sureMs) {
  try {
    _cihazTitretJs(sureMs);
  } catch (_) {}
}

void bildirimSesiCalBridge(String baslik, String icerik) {
  try {
    _bildirimSesiCalJs(baslik, icerik);
  } catch (_) {}
}

void tesbihSesiCalBridge() {
  // Web ortamında sistem tıklama sesi
}
