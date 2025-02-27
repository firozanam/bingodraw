import 'package:firebase_core/firebase_core.dart';

// TODO: Replace with actual Firebase configuration from Firebase Console
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'your-api-key',
      appId: 'your-app-id',
      messagingSenderId: 'your-sender-id',
      projectId: 'your-project-id',
      storageBucket: 'your-storage-bucket',
    );
  }
}