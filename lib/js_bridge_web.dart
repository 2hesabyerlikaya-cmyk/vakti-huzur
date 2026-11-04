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

bool pusulaNativeTrueNorthMuBridge() => false;

double pusulaManyetikAlanSiddetiOkuBridge() => 46.5;

bool pusulaKalibrasyonGerekliMiBridge() => false;

bool pusulaMasaustuModundaMiBridge() => true;

double pusulaEgimPitchOkuBridge() => 0.0;

double pusulaEgimRollOkuBridge() => 0.0;

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

Future<void> bildirimSesiCalBridge(
  String baslik,
  String icerik, {
  String sesModu = 'ezan',
}) async {
  if (sesModu == 'sessiz') return;
  try {
    _bildirimSesiCalJs(baslik, icerik);
  } catch (_) {}
}

Future<void> bildirimSesiDurdurBridge() async {}

void tesbihSesiCalBridge() {}
