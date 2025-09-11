plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ADD THESE LINES RIGHT HERE:
val flutterVersionCode = property("flutter.versionCode").toString().toIntOrNull() ?: 1
val flutterVersionName = property("flutter.versionName").toString()
val flutterCompileSdkVersion = property("flutter.compileSdkVersion").toString().toIntOrNull() ?: 34
val flutterMinSdkVersion = property("flutter.minSdkVersion").toString().toIntOrNull() ?: 21
val flutterTargetSdkVersion = property("flutter.targetSdkVersion").toString().toIntOrNull() ?: 34
val flutterNdkVersion = property("flutter.ndkVersion").toString()

android {
    namespace = "com.example.mapbox_nigeria_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mapbox_nigeria_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
