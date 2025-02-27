import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web configuration provided. Add your web configuration first.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'No iOS configuration provided. Add your iOS configuration first.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'No macOS configuration provided. Add your macOS configuration first.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'No Windows configuration provided. Add your Windows configuration first.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'No Linux configuration provided. Add your Linux configuration first.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );
}