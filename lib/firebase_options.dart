import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_qBlQ2NUuuyuXiNfQdqN7SjkXug-819A',
    appId: '1:323597227756:android:af69bd4a234d367a64f7c9',
    messagingSenderId: '323597227756',
    projectId: 'my-hisab-72265',
    storageBucket: 'my-hisab-72265.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD_qBlQ2NUuuyuXiNfQdqN7SjkXug-819A',
    appId: '1:323597227756:web:af69bd4a234d367a64f7c9',
    messagingSenderId: '323597227756',
    projectId: 'my-hisab-72265',
    storageBucket: 'my-hisab-72265.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_qBlQ2NUuuyuXiNfQdqN7SjkXug-819A',
    appId: '1:323597227756:ios:af69bd4a234d367a64f7c9',
    messagingSenderId: '323597227756',
    projectId: 'my-hisab-72265',
    storageBucket: 'my-hisab-72265.firebasestorage.app',
  );
}
