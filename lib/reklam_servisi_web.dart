import 'package:flutter/material.dart';
import 'translations_and_logo.dart';

Future<void> reklamServisiniBaslat() async {}

class InceBannerReklamWidget extends StatelessWidget {
  final IslamiTema tema;
  const InceBannerReklamWidget({super.key, required this.tema});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KullaniciProfilServisi.premiumNotifier,
      builder: (context, premium, _) {
        if (premium) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          color: tema.karanlikMi ? tema.arkaPlan : const Color(0xFF0F3D2E),
          child: Container(
            width: 320,
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: tema.kartRengi,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: tema.vurguAltin.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: tema.vurguAltin),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google AdMob Reklam Alanı',
                      style: TextStyle(
                        color: tema.yaziRengi,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '✨ Helal & İslami Aile Güvenliği Filtresi Aktif',
                      style: TextStyle(
                        color: tema.vurguAltin,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InterstitialReklamYoneticisi {
  static void oncedenYukle() {}
  static void goster({VoidCallback? onKapatildi}) {
    onKapatildi?.call();
  }
}
