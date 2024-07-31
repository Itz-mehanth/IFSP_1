// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// final authServiceProvider = Provider((ref) => AuthService());

// class AuthService with ChangeNotifier {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   bool _isSignedIn = false;

//   bool get isSignedIn => _isSignedIn;

//   Future<void> signInWithGoogle() async {
//     final account = await _googleSignIn.signIn();
//     if (account != null) {
//       _isSignedIn = true;
//       notifyListeners();
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     _isSignedIn = false;
//     notifyListeners();
//   }
// }