import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
import 'package:flutter/foundation.dart';
import 'dart:async';



class AuthService with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
    clientId: '471955095135-a4l01pd92gi4do8l8t8omp0t7032q4rj.apps.googleusercontent.com'
  );

  bool get isLoggedIn => _googleSignIn.currentUser!= null;

  Future<void> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signInSilently();
      if (user != null) {
        // User is signed in, you can access their email address
        final email = user.email;
        print('Signed in with email: $email');
      } else {
        // User is not signed in, prompt them to sign in
        await _googleSignIn.signIn();
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
       _googleSignIn.currentUser!= null;
      notifyListeners();
    } catch (e) {
      print('Error signing out with Google: $e');
    }
  }

  // Future<void> getContactInformation() async {
  //   if (_currentUser == null) return;
  //   final http.Response response = await http.get(
  //     Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //         '?requestMask.includeField=person.names'),
  //     headers: await _currentUser!.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //     print('Error getting contact information: ${response.statusCode}');
  //     return;
  //   }
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   final String? namedContact = _pickFirstNamedContact(data);
  //   print('Contact information: $namedContact');
  // }

  // String? _pickFirstNamedContact(Map<String, dynamic> data) {
  //   // Implement your logic to extract the contact information
  // }
}