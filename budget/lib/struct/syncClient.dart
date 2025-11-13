import 'dart:async';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/walletEntry.dart';
// import 'package:drift/web.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// Google Drive导入已删除
// import 'package:googleapis/drive/v3.dart' as drive;
// dart:io导入已删除
// import 'dart:io';

bool isSyncBackupFile(String? backupFileName) {
  if (backupFileName == null) return false;
  return backupFileName.contains("sync-");
}

bool isCurrentDeviceSyncBackupFile(String? backupFileName) {
  if (backupFileName == null) return false;
  return backupFileName == getCurrentDeviceSyncBackupFileName();
}

String getCurrentDeviceSyncBackupFileName({String? clientIDForSync}) {
  if (clientIDForSync == null) clientIDForSync = clientID;
  return "sync-" + clientIDForSync + ".sqlite";
}

String getDeviceFromSyncBackupFileName(String? backupFileName) {
  if (backupFileName == null) return "";
  return (backupFileName).replaceAll("sync-", "").split("-")[0];
}

String getCurrentDeviceName() {
  return (clientID).split("-")[0];
}

Future<DateTime> getDateOfLastSyncedWithClient(String clientIDForSync) async {
  String string =
      sharedPreferences.getString("dateOfLastSyncedWithClient") ?? "{}";
  String lastTimeSynced =
      (jsonDecode(string)[clientIDForSync] ?? "").toString();
  if (lastTimeSynced == "") return DateTime(0);
  try {
    return DateTime.parse(lastTimeSynced);
  } catch (e) {
    print("Error getting time of last sync " + e.toString());
    return DateTime(0);
  }
}

Future<bool> setDateOfLastSyncedWithClient(
    String clientIDForSync, DateTime dateTimeSynced) async {
  String string =
      sharedPreferences.getString("dateOfLastSyncedWithClient") ?? "{}";
  dynamic parsed = jsonDecode(string);
  parsed[clientIDForSync] = dateTimeSynced.toString();
  await sharedPreferences.setString(
      "dateOfLastSyncedWithClient", jsonEncode(parsed));
  return true;
}

// if changeMadeSync show loading and check if syncEveryChange is turned on
Timer? syncTimeoutTimer;
Debouncer backupDebounce = Debouncer(milliseconds: 5000);
// Google Drive功能已被禁用
Future<bool> createSyncBackup(
    {bool changeMadeSync = false,
    bool changeMadeSyncWaitForDebounce = true}) async {
  print("Google Drive同步功能已被禁用");
  if (changeMadeSync)
    loadingIndeterminateKey.currentState?.setVisibility(false);
  return false;
}

class SyncLog {
  SyncLog({
    this.deleteLogType,
    this.updateLogType,
    required this.transactionDateTime,
    required this.pk,
    this.itemToUpdate,
  });

  DeleteLogType? deleteLogType;
  UpdateLogType? updateLogType;
  DateTime? transactionDateTime;
  String pk;
  dynamic itemToUpdate;

  @override
  String toString() {
    return "SyncLog(deleteLogType: $deleteLogType, updateLogType: $updateLogType, transactionDateTime: $transactionDateTime, pk: $pk, itemToUpdate: $itemToUpdate)";
  }
}

// Only allow one sync at a time
bool canSyncData = true;

bool requestSyncDataCancel = false;

CancelableCompleter<bool> syncDataCompleter = CancelableCompleter(onCancel: () {
  requestSyncDataCancel = true;
});

Future<dynamic> cancelAndPreventSyncOperation() async {
  requestSyncDataCancel = true;
  return await syncDataCompleter.operation.cancel();
}

// Google Drive功能已被禁用
Future<bool> runForceSignIn(BuildContext context) async {
  print("Google Drive强制登录功能已被禁用");
  return false;
}

Future<bool> syncData(BuildContext context) async {
  // Google Drive同步功能已被禁用
  print("Google Drive同步功能已被禁用");
  return false;
}

// load the latest backup and import any newly modified data into the db
Future<bool> _syncData(BuildContext context) async {
  // Google Drive同步功能已被禁用
  print("Google Drive同步功能已被禁用");
  return false;
}
