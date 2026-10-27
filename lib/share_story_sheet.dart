import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;
import 'quran_api_service.dart';
import 'quran_hadith_data.dart';
import 'translations_and_logo.dart';

class PaylasimStoryBottomSheet extends StatefulWidget {
  final DinamikReelsKart kart;
  final String dil;

  const PaylasimStoryBottomSheet({
    super.key,
    required this.kart,
    required this.dil,
  });

  static void goster(BuildContext context, DinamikReelsKart kart, String dil) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaylasimStoryBottomSheet(kart: kart, dil: dil),
    );
  }

  @override
  State<PaylasimStoryBottomSheet> createState() => _PaylasimStoryBottomSheetState();
}

class _PaylasimStoryBottomSheetState extends State<PaylasimStoryBottomSheet> {
  final GlobalKey _storyKey = GlobalKey();
  bool _islemYapiliyor = false;

  String get _paylasimMetni {
    final k = widget.kart;
    final dil = widget.dil;
    return '${k.arapcaMetin}\n\n${k.meal(dil)}\n— ${k.kaynakKisa(dil)}\n\n✨ Vakt-i Huzur';
  }

  Future<void> _gorseliIndir({bool instagramIcin = false}) async {
    if (_islemYapiliyor) return;
    setState(() => _islemYapiliyor = true);

    try {
      final boundary =
          _storyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final base64Png = base64Encode(bytes);
          final dataUrl = 'data:image/png;base64,$base64Png';

          final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
          anchor.href = dataUrl;
          anchor.download = 'vakti_huzur_story_${widget.kart.id}.png';
          anchor.click();
        }
      }

      if (instagramIcin) {
        await Clipboard.setData(ClipboardData(text: _paylasimMetni));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF123C2D),
            behavior: SnackBarBehavior.floating,
            content: Text(
              instagramIcin
                  ? '9:16 Instagram Story görseli indirildi ve metin panoya kopyalandı!'
                  : '9:16 yüksek çözünürlüklü Story görseli indirildi!',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Görsel hazırlanırken bir hata oluştu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _islemYapiliyor = false);
    }
  }

  void _whatsAppIleGonder() {
    final encoded = Uri.encodeComponent(_paylasimMetni);
    web.window.open('https://wa.me/?text=$encoded', '_blank');
    Navigator.pop(context);
  }

  void _metniKopyala() {
    Clipboard.setData(ClipboardData(text: _paylasimMetni));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF123C2D),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Ayet/Hadis metni "Vakt-i Huzur" imzasıyla panoya kopyalandı.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldAccent = Color(0xFFD4AF37);
    const Color softGold = Color(0xFFF3E5AB);
    final k = widget.kart;
    final dil = widget.dil;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2119),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: goldAccent, width: 1.2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutamaç Çizgisi
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: goldAccent.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hikaye (9:16 Story) & Mesaj Olarak Paylaş',
              style: TextStyle(
                fontFamily: 'Lora',
                color: softGold,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // 9:16 INSTAGRAM STORY KART ÖNİZLEMESİ
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 370),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: RepaintBoundary(
                  key: _storyKey,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: k.arkaPlanRenkleri,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: goldAccent.withValues(alpha: 0.65),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ReelsIslamiDesenPainter(
                                desenTipi: k.desenIndex,
                                altinRenk: goldAccent,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Üst Etiket
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: goldAccent.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: goldAccent.withValues(alpha: 0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    k.turBasligi(dil),
                                    style: const TextStyle(
                                      color: softGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Orta: Arapça Hat, Türkçe Meal ve Kaynak
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            k.arapcaMetin,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 19,
                                              height: 1.65,
                                              color: softGold,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            k.meal(dil),
                                            textAlign: TextAlign.center,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Lora',
                                              fontSize: 11.5,
                                              height: 1.4,
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '— ${k.kaynakKisa(dil)} —',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: goldAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Alt: Uygulama Logosu & "Vakt-i Huzur" İmzası
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: goldAccent.withValues(alpha: 0.4),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ModernIslamiLogo(boyut: 20),
                                      SizedBox(width: 7),
                                      Text(
                                        'Vakt-i Huzur',
                                        style: TextStyle(
                                          fontFamily: 'Lora',
                                          color: softGold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4 PAYLAŞIM BUTONU (Instagram Story, WhatsApp, Görseli İndir, Metni Kopyala)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _PaylasimAksiyonButon(
                  ikon: Icons.camera_alt_outlined,
                  baslik: 'Instagram Story',
                  arkaPlan: const Color(0xFFC13584),
                  onTap: () => _gorseliIndir(instagramIcin: true),
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.chat_bubble_outline_rounded,
                  baslik: 'WhatsApp ile Gönder',
                  arkaPlan: const Color(0xFF25D366),
                  onTap: _whatsAppIleGonder,
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.download_rounded,
                  baslik: 'Görseli İndir',
                  arkaPlan: const Color(0xFF164E3B),
                  altinKenar: true,
                  onTap: () => _gorseliIndir(instagramIcin: false),
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.copy_rounded,
                  baslik: 'Metni Kopyala',
                  arkaPlan: const Color(0xFF164E3B),
                  altinKenar: true,
                  onTap: _metniKopyala,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaylasimAksiyonButon extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final Color arkaPlan;
  final bool altinKenar;
  final VoidCallback onTap;

  const _PaylasimAksiyonButon({
    required this.ikon,
    required this.baslik,
    required this.arkaPlan,
    this.altinKenar = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: arkaPlan,
          borderRadius: BorderRadius.circular(14),
          border: altinKenar
              ? Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(
              baslik,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
