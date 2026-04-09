import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> syncUser(User user) async {
    /// 🔥 FIRESTORE
    await _db.collection("usuarios").doc(user.uid).set({
      "nome": user.displayName ?? "Sem nome",
      "email": user.email,
      "uid": user.uid,
      "ultimoAcesso": DateTime.now(),
      "perfil": "estudante",
      "ativo": true,
    }, SetOptions(merge: true));
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("Login cancelado");
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
