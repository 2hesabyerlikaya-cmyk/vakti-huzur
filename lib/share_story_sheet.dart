import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
  static const MethodChannel _nativeMediaChannel =
      MethodChannel('com.berat.vaktiberaat/native_media');

  final GlobalKey _storyKey = GlobalKey();
  bool _islemYapiliyor = false;

  String get _paylasimMetni {
    final k = widget.kart;
    final dil = widget.dil;
    return '${k.arapcaMetin}\n\n${k.meal(dil)}\n— ${k.kaynakKisa(dil)}\n\nVakt-i Beraat';
  }

  Future<Uint8List?> _storyKartiniPngyeCevir() async {
    try {
      await Future.delayed(const Duration(milliseconds: 30));
      final boundary =
          _storyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _gorseliGaleriyeIndir() async {
    if (_islemYapiliyor) return;
    setState(() => _islemYapiliyor = true);
    HapticFeedback.mediumImpact();

    try {
      final bytes = await _storyKartiniPngyeCevir();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('PNG oluşturulamadı');
      }

      final fileName = 'vakti_beraat_${widget.kart.id}_${DateTime.now().millisecondsSinceEpoch}.png';

      bool basarili = false;
      if (kIsWeb) {
        final base64Png = base64Encode(bytes);
        final dataUrl = 'data:image/png;base64,$base64Png';
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = dataUrl;
        anchor.download = fileName;
        anchor.click();
        basarili = true;
      } else {
        final sonuc = await _nativeMediaChannel.invokeMethod<bool>(
          'saveImageToGallery',
          {
            'bytes': bytes,
            'fileName': fileName,
          },
        );
        basarili = sonuc == true;
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF123C2D),
            behavior: SnackBarBehavior.floating,
            content: Text(
              basarili
                  ? Ceviri.sec(
                      widget.dil,
                      tr: 'Galeriye kaydedildi',
                      en: 'Saved to gallery',
                      de: 'In der Galerie gespeichert',
                      fr: 'Enregistré dans la galerie',
                    )
                  : Ceviri.sec(
                      widget.dil,
                      tr: 'Galeri izni verilmedi veya kaydedilemedi.',
                      en: 'Could not save to gallery.',
                      de: 'Konnte nicht gespeichert werden.',
                      fr: 'Impossible d’enregistrer dans la galerie.',
                    ),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  Future<void> _storyPaylas({required String hedef}) async {
    if (_islemYapiliyor) return;
    setState(() => _islemYapiliyor = true);
    HapticFeedback.mediumImpact();

    try {
      final bytes = await _storyKartiniPngyeCevir();
      await Clipboard.setData(ClipboardData(text: _paylasimMetni));

      if (kIsWeb) {
        if (hedef == 'whatsapp') {
          final encoded = Uri.encodeComponent(_paylasimMetni);
          web.window.open('https://wa.me/?text=$encoded', '_blank');
        } else if (bytes != null) {
          final base64Png = base64Encode(bytes);
          final dataUrl = 'data:image/png;base64,$base64Png';
          final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
          anchor.href = dataUrl;
          anchor.download = 'vakti_beraat_story_${widget.kart.id}.png';
          anchor.click();
        }
        if (mounted) Navigator.pop(context);
        return;
      }

      if (bytes != null && bytes.isNotEmpty) {
        await _nativeMediaChannel.invokeMethod<bool>(
          'shareImage',
          {
            'bytes': bytes,
            'fileName': 'vakti_beraat_story_${widget.kart.id}.png',
            'text': _paylasimMetni,
            'target': hedef,
          },
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım penceresi açılırken bir hata oluştu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _islemYapiliyor = false);
    }
  }

  Future<void> _metniKopyala() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: _paylasimMetni));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF123C2D),
        behavior: SnackBarBehavior.floating,
        content: Text(
          Ceviri.sec(
            widget.dil,
            tr: 'Metin kopyalandı',
            en: 'Text copied to clipboard',
            de: 'Text in die Zwischenablage kopiert',
            fr: 'Texte copié dans le presse-papiers',
          ),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            Text(
              Ceviri.sec(
                dil,
                tr: 'Hikaye (9:16 Story) & Mesaj Olarak Paylaş',
                en: 'Share as 9:16 Story & Message',
                de: 'Als 9:16 Story & Nachricht teilen',
                fr: 'Partager en Story 9:16 & Message',
              ),
              style: const TextStyle(
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
                                // Dinamik Üst Etiket ("Esmaü'l Hüsna", "Günün Ayeti", "Hadis-i Şerif", "Dua")
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

                                // Orta: Arapça Hat, Meal ve Kaynak
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

                                // Alt: Uygulama Logosu & "Vakt-i Beraat" İmzası
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
                                        'Vakt-i Beraat',
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

            // 4 PAYLAŞIM BUTONU (Instagram Story, WhatsApp ile Gönder, Görseli İndir, Metni Kopyala)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _PaylasimAksiyonButon(
                  ikon: Icons.camera_alt_outlined,
                  baslik: 'Instagram Story',
                  arkaPlan: const Color(0xFFC13584),
                  onTap: () => _storyPaylas(hedef: 'instagram'),
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.chat_bubble_outline_rounded,
                  baslik: Ceviri.sec(
                    dil,
                    tr: 'WhatsApp ile Gönder',
                    en: 'Send via WhatsApp',
                    de: 'Über WhatsApp senden',
                    fr: 'Envoyer via WhatsApp',
                  ),
                  arkaPlan: const Color(0xFF25D366),
                  onTap: () => _storyPaylas(hedef: 'whatsapp'),
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.download_rounded,
                  baslik: Ceviri.sec(
                    dil,
                    tr: 'Görseli İndir',
                    en: 'Save Image',
                    de: 'Bild speichern',
                    fr: 'Enregistrer l’image',
                  ),
                  arkaPlan: const Color(0xFF164E3B),
                  altinKenar: true,
                  onTap: _gorseliGaleriyeIndir,
                ),
                _PaylasimAksiyonButon(
                  ikon: Icons.copy_rounded,
                  baslik: Ceviri.sec(
                    dil,
                    tr: 'Metni Kopyala',
                    en: 'Copy Text',
                    de: 'Text kopieren',
                    fr: 'Copier le texte',
                  ),
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
    return Material(
      color: arkaPlan,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: altinKenar
                ? Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                  )
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
