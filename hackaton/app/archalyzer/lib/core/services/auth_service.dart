import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Get the auth token. Signs in anonymously if this is the first time.
  Future<String?> getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // If there's no user, sign in silently
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      
      // Now get the token for the current user (anonymous or otherwise)
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      
      if (idToken == null) {
        throw Exception("Could not retrieve ID Token.");
      }
      
      return idToken;
    } catch (e) {
      print("Error getting auth token: $e");
      return null;
    }
  }
}