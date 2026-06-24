import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'this app only targets Android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTt6Uv5EdQDrFlK8cwn74DLaqEkkINZ8s',
    appId: '1:688927756155:android:7bc46c48db0c89c6a1f7de',
    messagingSenderId: '688927756155',
    projectId: 'bank-sampah-azka',
    storageBucket: 'bank-sampah-azka.firebasestorage.app',
  );
}