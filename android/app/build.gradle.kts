import java.io.FileInputStream
import java.security.KeyStore

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystoreFile = file("vakti-beraat-upload.jks")
val releaseKeystorePass = "VaktiBeraat2026!"
val detectedKeyAlias: String = if (releaseKeystoreFile.exists()) {
    val ks = KeyStore.getInstance("PKCS12")
    FileInputStream(releaseKeystoreFile).use { ks.load(it, releaseKeystorePass.toCharArray()) }
    if (ks.aliases().hasMoreElements()) ks.aliases().nextElement() else "vaktiberaat"
} else {
    "vaktiberaat"
}

android {
    namespace = "com.berat.vaktiberaat"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.berat.vaktiberaat"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (releaseKeystoreFile.exists()) {
                storeFile = releaseKeystoreFile
                storePassword = releaseKeystorePass
                keyAlias = detectedKeyAlias
                keyPassword = releaseKeystorePass
                storeType = "PKCS12"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeystoreFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
