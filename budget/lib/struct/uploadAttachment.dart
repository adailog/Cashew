import 'dart:io';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
// Google Drive导入已删除 - import 'package:googleapis/drive/v3.dart' as drive;

// Google Drive功能已被禁用
Future<String?> getPhotoAndUpload({required ImageSource source}) async {
  openSnackbar(
    SnackbarMessage(
      title: "功能已禁用".tr(),
      description: "Google Drive上传功能已被禁用".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.info_outlined
          : Icons.info_rounded,
    ),
  );
  return null;
}

// Google Drive功能已被禁用
Future<String?> getFileAndUpload() async {
  openSnackbar(
    SnackbarMessage(
      title: "功能已禁用".tr(),
      description: "Google Drive上传功能已被禁用".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.info_outlined
          : Icons.info_rounded,
    ),
  );
  return null;
}

// Google Drive功能已被禁用
Future<String?> uploadFileToDrive({
  required Stream<List<int>> mediaStream,
  required Uint8List fileBytes,
  required String fileName,
}) async {
  print("Google Drive上传功能已被禁用");
  return null;
}
