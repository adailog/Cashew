import 'dart:async';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:drift/drift.dart' hide Query, Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Firebase相关导入已删除
// import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';

Future<bool> shareBudget(Budget? budgetToShare, context) async {
  // Firebase功能已被禁用
  openSnackbar(SnackbarMessage(title: "共享预算功能已被禁用"));
  return false;
}

Future<bool> removedSharedFromBudget(Budget sharedBudget,
    {bool removeFromServer = true}) async {
  // Firebase功能已被禁用
  openSnackbar(SnackbarMessage(title: "共享预算功能已被禁用"));
  return false;
}

Future<bool> leaveSharedBudget(Budget sharedBudget) async {
  // Firebase功能已被禁用
  openSnackbar(SnackbarMessage(title: "共享预算功能已被禁用"));
  return false;
}

Future<bool> addMemberToBudget(
    String sharedKey, String member, Budget budget) async {
  // Firebase功能已被禁用
  openSnackbar(SnackbarMessage(title: "共享预算功能已被禁用"));
  return false;
}

Future<bool> removeMemberFromBudget(
    String sharedKey, String member, Budget budget) async {
  // Firebase功能已被禁用
  openSnackbar(SnackbarMessage(title: "共享预算功能已被禁用"));
  return false;
}

// the owner is always the first entry!
Future<dynamic> getMembersFromBudget(String sharedKey, Budget budget) async {
  // Firebase功能已被禁用
  return null;
}

Future<bool> compareSharedToCurrentBudgets(
    List<dynamic> budgetSnapshot) async {
  // Firebase功能已被禁用
  return false;
}

Timer? cloudTimeoutTimer;
Future<bool> getCloudBudgets() async {
  // Firebase功能已被禁用
  return false;
}

Future<int> downloadTransactionsFromBudgets(
    dynamic db, List<dynamic> snapshots) async {
  // Firebase功能已被禁用
  return 0;
}

Future<bool> sendTransactionSet(Transaction transaction, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

// update the entry on the server
Future<bool> setOnServer(dynamic db, Transaction transaction, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> sendTransactionAdd(Transaction transaction, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> addOnServer(dynamic db, Transaction transaction, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> sendTransactionDelete(
    Transaction transaction, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> deleteOnServer(dynamic db, String? transactionSharedKey, Budget budget) async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> syncPendingQueueOnServer() async {
  // Firebase功能已被禁用
  return false;
}

Future<bool> updateTransactionOnServerAfterChangingCategoryInformation(
    TransactionCategory category) async {
  // Firebase功能已被禁用
  return false;
}
