# ============================================================================
# Vakt-i Beraat — R8 / ProGuard Kod Karartma (Obfuscation) ve Güvenlik Kuralları
# ============================================================================

# 1. Üretim (Release) Sürümünde Tüm Debug / Verbose / Info Loglarını Tamamen Sil
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
-assumenosideeffects class java.io.PrintStream {
    public void print(...);
    public void println(...);
}

# 2. Flutter Engine ve Plugin Kayıt Sınıflarını Koru
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 3. Uygulama Ana Sınıfı ve Widget BroadcastReceiver Sınıflarını Koru
-keep class com.berat.vaktiberaat.MainActivity { *; }
-keep class com.berat.vaktiberaat.*WidgetProvider { *; }
-keep class es.antonborri.home_widget.** { *; }

# 4. Bildirim Alıcılarını (flutter_local_notifications & GSON) Koru
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.media.** { *; }
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# 5. Google Mobile Ads (AdMob) Sınıflarını Koru ve Uyarıları Bastır
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.errorprone.annotations.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
