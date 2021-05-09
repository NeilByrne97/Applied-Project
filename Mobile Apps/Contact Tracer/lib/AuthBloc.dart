
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'AuthService.dart';

class AuthBloc{
  final authService = AuthService();
  final googleSignIn = GoogleSignIn(scopes: ['email']);

  Stream<User> get currentUser => authService.currentUser;

  loginGoogle() async {
    try{
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
      );

      // Firebase Sign In
      final result = await authService.signInWithCredential(credential);
      print('${result.user.displayName}');

    }catch(error){
      print(error);
    }
  }

  logout(){
    authService.logout();
  }

}