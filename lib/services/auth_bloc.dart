import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rating_chat2/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc {
  final authService = AuthService();
  final googleSignin = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Stream<User?> get currentUser => authService.currentUser;

  Future loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignin.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth!.idToken, accessToken: googleAuth.accessToken);

      final result = await authService.signInWithCredential(credential);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      DocumentSnapshot userExist = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userExist.exists) {
        print("already in");
      } else {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'image': userCredential.user!.photoURL,
          'uid': userCredential.user!.uid,
        });
      }
    } catch (error) {
      print(error);
    }
  }

  logout() {
    googleSignin.signOut();
    authService.logout();
  }
}
