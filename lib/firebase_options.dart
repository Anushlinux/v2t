// This is a temporary stub file.
// Run 'flutterfire configure' to generate the actual firebase_options.dart file.
//
// To generate this file:
// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
// 2. Login to Firebase: firebase login
// 3. Configure: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA89erpmCcEkyM6sHJN80BjxwwqLhnoocA',
    appId: '1:324294670777:web:163615b908dd750eae5e68',
    messagingSenderId: '324294670777',
    projectId: 'flutter-6cd66',
    authDomain: 'flutter-6cd66.firebaseapp.com',
    storageBucket: 'flutter-6cd66.firebasestorage.app',
    measurementId: 'G-175CZTK2P1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCN1dpM-TGZxv3eVJmEMowtxsczMcgpCOk',
    appId: '1:324294670777:ios:259f67e88fcc54e3ae5e68',
    messagingSenderId: '324294670777',
    projectId: 'flutter-6cd66',
    storageBucket: 'flutter-6cd66.firebasestorage.app',
    iosBundleId: 'com.example.v2t',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCN1dpM-TGZxv3eVJmEMowtxsczMcgpCOk',
    appId: '1:324294670777:ios:259f67e88fcc54e3ae5e68',
    messagingSenderId: '324294670777',
    projectId: 'flutter-6cd66',
    storageBucket: 'flutter-6cd66.firebasestorage.app',
    iosBundleId: 'com.example.v2t',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD148dQ8bQsDUxuFr0DNWTvpjCDlJa2GC8',
    appId: '1:324294670777:android:15fd40c8207acaeeae5e68',
    messagingSenderId: '324294670777',
    projectId: 'flutter-6cd66',
    storageBucket: 'flutter-6cd66.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA89erpmCcEkyM6sHJN80BjxwwqLhnoocA',
    appId: '1:324294670777:web:03405ca81f0b3c21ae5e68',
    messagingSenderId: '324294670777',
    projectId: 'flutter-6cd66',
    authDomain: 'flutter-6cd66.firebaseapp.com',
    storageBucket: 'flutter-6cd66.firebasestorage.app',
    measurementId: 'G-KZWRHTSXP1',
  );

}