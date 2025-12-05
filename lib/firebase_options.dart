// lib/firebase_options.dart
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
        return ios; // optional
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ----- Web config (for Chrome/Web testing) -----
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDg7MCb5ZYSaaUCpWC_2dBSLlK9K89ib2Y',
    authDomain: 'my-flutter-app-f0390.firebaseapp.com',
    projectId: 'my-flutter-app-f0390',
    storageBucket: 'my-flutter-app-f0390.firebasestorage.app',
    messagingSenderId: '99683360558',
    appId: '1:99683360558:web:7926b0ec3cdc9710b964bf',
    measurementId: 'G-FXYCX6L4BQ',
  );

  // ----- Android config (from google-services.json) -----
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB49LWKslst8YTcg4Q0KcyL0h2reojd6aA',
    appId: '1:99683360558:android:1989b4f688654b5fb964bf',
    messagingSenderId: '99683360558',
    projectId: 'my-flutter-app-f0390',
    storageBucket: 'my-flutter-app-f0390.firebasestorage.app',
  );

  // ----- iOS (optional, leave blank for now) -----
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
  );
}
