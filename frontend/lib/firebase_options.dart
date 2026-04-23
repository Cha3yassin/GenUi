// File generated manually from Firebase Console web config.
// Project: fberaucracy

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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Web configuration from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATTMAAzVJ48w49vAEG0ZYTwrrsDQAFQK8',
    appId: '1:695805257900:web:00324d08e39ac135905709',
    messagingSenderId: '695805257900',
    projectId: 'fberaucracy',
    authDomain: 'fberaucracy.firebaseapp.com',
    storageBucket: 'fberaucracy.firebasestorage.app',
    measurementId: 'G-GRGLJ7W4TR',
  );

  // Android — placeholder until you add an Android app in Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATTMAAzVJ48w49vAEG0ZYTwrrsDQAFQK8',
    appId: '1:695805257900:web:00324d08e39ac135905709',
    messagingSenderId: '695805257900',
    projectId: 'fberaucracy',
    storageBucket: 'fberaucracy.firebasestorage.app',
  );

  // iOS — placeholder until you add an iOS app in Firebase Console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATTMAAzVJ48w49vAEG0ZYTwrrsDQAFQK8',
    appId: '1:695805257900:web:00324d08e39ac135905709',
    messagingSenderId: '695805257900',
    projectId: 'fberaucracy',
    storageBucket: 'fberaucracy.firebasestorage.app',
    iosBundleId: 'com.fbureaucracy.app',
  );
}
