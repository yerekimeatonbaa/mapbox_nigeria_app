import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val flutterProperties = Properties().apply {
    load(File(project.rootDir, "flutter.properties").inputStream())
}

val flutterVersionCode = flutterProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = flutterProperties.getProperty("flutter.versionName") ?: "1.0"
val flutterCompileSdkVersion = flutterProperties.getProperty("flutter.compileSdkVersion")?.toIntOrNull() ?: 34
val flutterMinSdkVersion = flutterProperties.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: 21
val flutterTargetSdkVersion = flutterProperties.getProperty("flutter.targetSdkVersion")?.toIntOrNull() ?: 34
val flutterNdkVersion = flutterProperties.getProperty("flutter.ndkVersion") ?: ""

android {
    namespace = "com.example.mapbox_nigeria_app"
    compileSdk = flutterCompileSdkVersion
    ndkVersion = flutterNdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.mapbox_nigeria_app"
        minSdk = flutterMinSdkVersion
        targetSdk = flutterTargetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}