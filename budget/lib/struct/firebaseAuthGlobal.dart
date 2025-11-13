import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
// Firebase相关导入已删除
// import 'package:firebase_auth/firebase_auth.dart';
// Google Sign In导入已删除
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

// OAuthCredential类型已被删除
// OAuthCredential? _credential;

// Firebase Firestore类型已被替换为dynamic
Future<dynamic> firebaseGetDBInstanceAnonymous() async {
  try {
    // Firebase匿名登录功能已被禁用
    print("Firebase匿名登录功能已被禁用");
    return null;
  } catch (e) {
    print("There was an error with firebase login");
    print(e.toString());
    return null;
  }
}

// Google Drive功能已被禁用
Future<dynamic> firebaseGetDBInstance() async {
  print("Google Firebase认证功能已被禁用");
  return null;
}
