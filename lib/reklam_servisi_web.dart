import 'package:flutter/material.dart';
import 'translations_and_logo.dart';

Future<void> reklamServisiniBaslat() async {}

class InceBannerReklamWidget extends StatelessWidget {
  final IslamiTema tema;
  const InceBannerReklamWidget({super.key, required this.tema});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class InterstitialReklamYoneticisi {
  static void oncedenYukle() {}
  static void goster({VoidCallback? onKapatildi}) {
    onKapatildi?.call();
  }
}
