import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Google Sign In导入已删除
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

OAuthCredential? _credential;

Future<FirebaseFirestore?> firebaseGetDBInstanceAnonymous() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    return FirebaseFirestore.instance;
  } catch (e) {
    print("There was an error with firebase login");
    print(e.toString());
    return null;
  }
}

// Google Drive功能已被禁用
Future<FirebaseFirestore?> firebaseGetDBInstance() async {
  print("Google Firebase认证功能已被禁用");
  return null;
}
