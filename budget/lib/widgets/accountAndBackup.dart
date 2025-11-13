import 'dart:async';
import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/firebase_options.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/struct/syncClient.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/exportCSV.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/importDB.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/saveFile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shimmer/shimmer.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:budget/struct/randomConstants.dart';

Future<bool> checkConnection() async {
  late bool isConnected;
  if (!kIsWeb) {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (e) {
      print(e.toString());
      isConnected = false;
    }
  } else {
    isConnected = true;
  }
  return isConnected;
}

// Google登录功能已完全移除

// 定义一个空的googleUser变量以避免编译错误
final dynamic googleUser = null;

// 保留这个函数以避免编译错误，但返回false表示登录失败
Future<bool> signInGoogle({
  bool silentSignIn = false,
  bool drivePermissionsAttachments = false,
}) async {
  print("Google登录功能已移除");
  return false;
}

// 移除了refreshGoogleSignIn函数的实现，但保留在文件其他位置的实现

void refreshUIAfterLoginChange() {
  // Google登录功能已移除，UI刷新功能不再需要
  sidebarStateKey.currentState?.refreshState();
  accountsPageStateKey.currentState?.refreshState();
  // 移除settingsGoogleAccountLoginButtonKey的refreshState调用
}

// Google登录相关函数已完全移除

// 仅保留一个简单的signOutGoogle函数以避免引用错误
Future<bool> signOutGoogle() async {
  return true;
}

// 仅保留一个简单的signInAndSync函数以避免引用错误
Future<bool> signInAndSync(BuildContext context,
    {required dynamic Function() next}) async {
  openSnackbar(
    SnackbarMessage(
      title: "功能已移除",
      description: "Google登录和同步功能已被移除",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.error_outlined
          : Icons.error_rounded,
    ),
  );
  return false;
}

// 清理Google登录相关的备份功能
Future<void> createBackupInBackground() async {
  // Google登录功能已移除，备份功能不再可用
  print("Backup functionality has been removed due to Google sign-in removal");
}

Future<bool> createBackup(BuildContext? context,
    {bool silentBackup = false,
    bool deleteOldBackups = false,
    String? clientIDForSync}) async {
  // Google登录功能已移除，备份功能不再可用
  print("Backup functionality has been removed due to Google sign-in removal");
  if (context != null && !silentBackup) {
    openSnackbar(
      SnackbarMessage(
        title: "功能已移除",
        description: "Google备份功能已被移除",
        icon: appStateSettings["outlinedIcons"]
            ? Icons.error_outlined
            : Icons.error_rounded,
      ),
    );
  }
  return false;
}

// 移除GoogleAuthClient类和其他Google登录相关类

// 简化剩余的函数以避免编译错误
Future<void> deleteBackup(dynamic driveApi, String fileId) async {
  // Google登录功能已移除，删除备份功能不再可用
}

Future<void> saveDriveFileToDevice(
    BuildContext context, dynamic driveApi, dynamic file) async {
  // Google登录功能已移除，保存备份功能不再可用
}

// 移除Google登录相关的备份管理类
class BackupManagement {
  // Google登录功能已移除，备份管理功能不再可用
  Future<(dynamic, List<dynamic>)> getDriveFiles() async {
    return (null, []);
  }
}

// GoogleAccountLoginButton组件已移除，因为Google登录功能已被移除
class GoogleAccountLoginButton extends StatefulWidget {
  const GoogleAccountLoginButton({
    super.key,
    this.navigationSidebarButton = false,
    this.isButtonSelected = false,
    this.isOutlinedButton = true,
    this.forceButtonName,
  });
  final bool navigationSidebarButton;
  final bool isButtonSelected;
  final bool isOutlinedButton;
  final String? forceButtonName;

  @override
  State<GoogleAccountLoginButton> createState() =>
      GoogleAccountLoginButtonState();
}

class GoogleAccountLoginButtonState extends State<GoogleAccountLoginButton> {
  @override
  Widget build(BuildContext context) {
    // 返回空占位组件，因为Google登录功能已移除
    return SizedBox.shrink();
  }
}

// 清理Google登录相关的设置UI
class SettingsGoogleAccountLoginButton extends StatefulWidget {
  const SettingsGoogleAccountLoginButton({super.key});

  @override
  State<SettingsGoogleAccountLoginButton> createState() =>
      SettingsGoogleAccountLoginButtonState();
}

class SettingsGoogleAccountLoginButtonState
    extends State<SettingsGoogleAccountLoginButton> {
  @override
  Widget build(BuildContext context) {
    // 返回空占位组件，因为Google登录功能已移除
    return SizedBox.shrink();
  }
}

// 清理备份设置组件
class BackupsSettings extends StatefulWidget {
  const BackupsSettings({super.key});

  @override
  State<BackupsSettings> createState() => BackupsSettingsState();
}

class BackupsSettingsState extends State<BackupsSettings> {
  @override
  Widget build(BuildContext context) {
    // 返回简单的提示组件，说明备份功能已移除
    return SettingsContainer(
      title: "备份功能已移除",
      description: "Google登录功能已移除，备份和同步功能不可用",
    );
  }
}

// 清理备份列表组件
class BackupsList extends StatefulWidget {
  const BackupsList({super.key});

  @override
  State<BackupsList> createState() => BackupsListState();
}

class BackupsListState extends State<BackupsList> {
  @override
  Widget build(BuildContext context) {
    // 返回空占位组件，因为Google登录功能已移除
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text("Google登录功能已移除，备份功能不可用"),
      ),
    );
  }
}

// 清理其他引用Google登录的函数
Future<bool> refreshGoogleSignIn() async {
  return false;
}

Future<bool> testIfHasGmailAccess() async {
  return false;
}

double convertBytesToMB(String bytesString) {
  try {
    int bytes = int.parse(bytesString);
    double megabytes = bytes / (1024 * 1024);
    return megabytes;
  } catch (e) {
    print("Error parsing bytes string: $e");
    return 0.0; // or throw an exception, depending on your requirements
  }
}

class LoadingShimmerDriveFiles extends StatelessWidget {
  const LoadingShimmerDriveFiles({
    Key? key,
    required this.isManaging,
    required this.i,
  }) : super(key: key);

  final bool isManaging;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period:
          Duration(milliseconds: (1000 + randomDouble[i % 10] * 520).toInt()),
      baseColor: appStateSettings["materialYou"]
          ? Theme.of(context).colorScheme.secondaryContainer
          : getColor(context, "lightDarkAccentHeavyLight"),
      highlightColor: appStateSettings["materialYou"]
          ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2)
          : getColor(context, "lightDarkAccentHeavy").withAlpha(20),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8.0),
        child: Tappable(
          onTap: () {},
          borderRadius: 15,
          color: appStateSettings["materialYou"]
              ? Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(0.5)
              : getColor(context, "lightDarkAccentHeavy").withOpacity(0.5),
          child: Container(
              padding:
                  EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          appStateSettings["outlinedIcons"]
                              ? Icons.description_outlined
                              : Icons.description_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.all(
                                      Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                height: 20,
                                width: 70 + randomDouble[i % 10] * 120 + 13,
                              ),
                              SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.all(
                                      Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                height: 14,
                                width: 90 + randomDouble[i % 10] * 120,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 13),
                  isManaging
                      ? Row(
                          children: [
                            ButtonIcon(
                                onTap: () {},
                                icon: appStateSettings["outlinedIcons"]
                                    ? Icons.close_outlined
                                    : Icons.close_rounded),
                            SizedBox(width: 5),
                            ButtonIcon(
                                onTap: () {},
                                icon: appStateSettings["outlinedIcons"]
                                    ? Icons.close_outlined
                                    : Icons.close_rounded),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              )),
        ),
      ),
    );
  }
}

// Google Drive功能已移除，移除重复的saveDriveFileToDevice函数
// Future<bool> saveDriveFileToDevice({
// Google Drive功能已移除，此函数已被禁用
// saveDriveFileToDevice({
//   required BuildContext boxContext,
//   required drive.DriveApi driveApi,
//   required drive.File fileToSave,
// }) async {
//   List<int> dataStore = [];
//   dynamic response = await driveApi.files
//       .get(fileToSave.id!, downloadOptions: drive.DownloadOptions.fullMedia);
//   await for (var data in response.stream) {
//     dataStore.insertAll(dataStore.length, data);
//   }
//   String fileName = "cashew-" +
//       ((fileToSave.name ?? "") +
//           cleanFileNameString(
//               (fileToSave.modifiedTime ?? DateTime.now()).toString()))
//           .replaceAll(".sqlite", "") +
//       ".sql";
//
//   return await saveFile(
//     boxContext: boxContext,
//     dataStore: dataStore,
//     dataString: null,
//     fileName: fileName,
//     successMessage: "backup-downloaded-success".tr(),
//     errorMessage: "error-downloading".tr(),
//   );
// }

bool openBackupReminderPopupCheck(BuildContext context) {
  if ((appStateSettings["currentUserEmail"] == null ||
          appStateSettings["currentUserEmail"] == "") &&
      ((appStateSettings["numLogins"] + 1) % 7 == 0) &&
      appStateSettings["canShowBackupReminderPopup"] == true) {
    openPopup(
      context,
      icon: MoreIcons.google_drive,
      iconScale: 0.9,
      title: "backup-your-data-reminder".tr(),
      description: "backup-your-data-reminder-description".tr() +
          " " +
          "google-drive".tr(),
      onSubmitLabel: "backup".tr().capitalizeFirst,
      onSubmit: () async {
        popRoute(context);
        await signInAndSync(context, next: () {});
      },
      onCancelLabel: "never".tr().capitalizeFirst,
      onCancel: () async {
        popRoute(context);
        await updateSettings("canShowBackupReminderPopup", false,
            updateGlobalState: false);
      },
      onExtraLabel: "later".tr().capitalizeFirst,
      onExtra: () {
        popRoute(context);
      },
    );
    return true;
  }
  return false;
}
