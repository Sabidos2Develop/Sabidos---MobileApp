import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> syncUser(User user) async {
    final docRef = _db.collection("usuarios").doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      /// 🔹 Usuário novo
      await docRef.set({
        "nome": user.displayName,
        "email": user.email,
        "uid": user.uid,
        "criadoEm": DateTime.now(),
        "perfil": "estudante",
        "ativo": true,
      });
    } else {
      /// 🔹 Usuário existente → atualiza acesso
      await docRef.update({"ultimoAcesso": DateTime.now()});
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final account = await googleSignIn.authenticate();

    if (account == null) {
      throw Exception("Login cancelado");
    }

    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw Exception("ID Token não encontrado");
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user;

    if (user == null) {
      throw Exception("Erro ao autenticar usuário");
    }

    await syncUser(user);

    return user;
  }

  Future<void> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await syncUser(cred.user!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
