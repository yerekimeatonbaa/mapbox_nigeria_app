# Trail App

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to get the debug certificate fingerprint

You can get the debug certificate fingerprint (SHA-1) using one of the following methods:

### Method 1: Using keytool

1.  Find the `debug.keystore` file. It is usually located in `~/.android/debug.keystore`.
2.  Run the following command:

    ```bash
    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
    ```

### Method 2: Using Gradle

1.  Open a terminal and navigate to the `android` directory of your project.
2.  Run the following command:

    ```bash
    ./gradlew signingReport
    ```

    This will generate a report that includes the SHA-1 and SHA-256 fingerprints for your debug certificate.