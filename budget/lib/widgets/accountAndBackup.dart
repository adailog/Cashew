import 'dart:async';
import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
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
// http包导入已删除
// import 'package:http/http.dart' as http;
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

// GoogleAuthClient类已被禁用
// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final http.Client _client = new http.Client();
//   GoogleAuthClient(this._headers);
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     // 网络请求已被禁用
//     print("Google认证网络请求已被禁用");
//     throw Exception("网络请求已被禁用");
//   }
// }

// Google登录相关变量已删除
// signIn.GoogleSignIn? googleSignIn;
final signIn.GoogleSignInAccount? googleUser = null; // 添加一个null值以避免编译错误

// Google登录功能已禁用
Future<bool> signInGoogle(
    {BuildContext? context,
    bool? waitForCompletion,
    bool? gMailPermissions,
    bool? drivePermissionsAttachments,
    bool? silentSignIn,
    Function()? next}) async {
  // 内联实现checkLockedFeatureIfInDemoMode功能
  if (appStateSettings["demoMode"] == true) {
    return false;
  }
  if (appStateSettings["emailScanning"] == false) gMailPermissions = false;

  // Google登录功能已禁用
  openSnackbar(
    SnackbarMessage(
      title: "功能已禁用".tr(),
      description: "Google登录和云服务功能已被禁用".tr(),
      icon: appStateSettings["outlinedIcons"] == true
          ? Icons.info_outlined
          : Icons.info_rounded,
    ),
  );
  return false;
}

Future<bool> testIfHasGmailAccess() async {
  // Gmail访问测试已禁用
  return false;
}

Future<bool> signOutGoogle() async {
  // Google登出功能已禁用
  print("Google登出功能已禁用");
  return true;
}

Future<bool> refreshGoogleSignIn() async {
  // Google登录刷新功能已禁用
  return false;
}

Future<bool> signInAndSync(BuildContext context,
    {required dynamic Function() next}) async {
  dynamic result = true;
  if (getPlatform() == PlatformOS.isIOS &&
      appStateSettings["hasSignedIn"] != true) {
    result = await openPopup(
      null,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.badge_outlined
          : Icons.badge_rounded,
      title: "backups".tr(),
      description: "google-drive-backup-disclaimer".tr(),
      onSubmitLabel: "continue".tr(),
      onSubmit: () {
        popRoute(null, true);
      },
      onCancel: () {
        popRoute(null);
      },
      onCancelLabel: "cancel".tr(),
    );
  }

  if (result != true) return false;
  loadingIndeterminateKey.currentState?.setVisibility(true);
  try {
    await signInGoogle(
      context: context,
      waitForCompletion: false,
      next: next,
    );
    // Google用户登录功能已禁用
    if (appStateSettings["username"] == "" && false) {
      await updateSettings("username", "",
          pagesNeedingRefresh: [0], updateGlobalState: false);
    }
    if (false) {
      loadingIndeterminateKey.currentState?.setVisibility(true);
      await syncData(context);
      loadingIndeterminateKey.currentState?.setVisibility(true);
      await syncPendingQueueOnServer();
      loadingIndeterminateKey.currentState?.setVisibility(true);
      await getCloudBudgets();
      loadingIndeterminateKey.currentState?.setVisibility(true);
      await createBackupInBackground(context);
    } else {
      throw ("cannot sync data - user not logged in");
    }
    loadingIndeterminateKey.currentState?.setVisibility(false);
    return true;
  } catch (e) {
    print("Error syncing data after login!");
    print(e.toString());
    loadingIndeterminateKey.currentState?.setVisibility(false);
    return false;
  }
}

Future<void> createBackupInBackground(context) async {
  if (appStateSettings["hasSignedIn"] == false) return;
  if (errorSigningInDuringCloud == true) return;
  if (kIsWeb && !entireAppLoaded) return;
  // print(entireAppLoaded);
  print("Last backup: " + appStateSettings["lastBackup"]);
  //Only run this once, don't run again if the global state changes (e.g. when changing a setting)
  // Update: Does this still run when global state changes? I don't think so...
  // If the entire app is loaded and we want to do an auto backup, lets do it no matter what!
  // if (entireAppLoaded == false || entireAppLoaded) {
  if (appStateSettings["autoBackups"] == true) {
    DateTime lastUpdate = DateTime.parse(appStateSettings["lastBackup"]);
    DateTime nextPlannedBackup = lastUpdate
        .add(Duration(days: appStateSettings["autoBackupsFrequency"]));
    print("next backup planned on " + nextPlannedBackup.toString());
    if (DateTime.now().millisecondsSinceEpoch >=
        nextPlannedBackup.millisecondsSinceEpoch) {
      print("auto backing up");

      bool hasSignedIn = false;
      // Google用户登录功能已禁用
      if (false) {
        hasSignedIn = await signInGoogle(
            context: context,
            gMailPermissions: false,
            waitForCompletion: false,
            silentSignIn: true);
      } else {
        hasSignedIn = false;
      }
      if (hasSignedIn == false) {
        return;
      }
      await createBackup(context, silentBackup: true, deleteOldBackups: true);
    } else {
      print("backup already made today");
    }
  }
  // }
  return;
}

Future forceDeleteDB() async {
  if (kIsWeb) {
    final html.Storage localStorage = html.window.localStorage;
    localStorage.clear();
  } else {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
    await dbFile.delete();
  }
}

bool openDatabaseCorruptedPopup(BuildContext context) {
  if (isDatabaseCorrupted) {
    openPopup(
      context,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.heart_broken_outlined
          : Icons.heart_broken_rounded,
      title: "database-corrupted".tr(),
      description: "database-corrupted-description".tr(),
      descriptionWidget: CodeBlock(
        text: databaseCorruptedError,
      ),
      barrierDismissible: false,
      onSubmit: () async {
        popRoute(context);
        await importDB(context, ignoreOverwriteWarning: true);
      },
      onSubmitLabel: "import-backup".tr(),
      onCancel: () async {
        popRoute(context);
        await openLoadingPopupTryCatch(() async {
          await forceDeleteDB();
          await sharedPreferences.clear();
        });
        restartAppPopup(context);
      },
      onCancelLabel: "reset".tr(),
    );
    // Lock the side navigation
    lockAppWaitForRestart = true;
    appStateKey.currentState?.refreshAppState();
    return true;
  }
  return false;
}

Future<void> createBackup(
  context, {
  bool? silentBackup,
  bool deleteOldBackups = false,
  String? clientIDForSync,
}) async {
  // 云备份功能已禁用
  if (silentBackup == false || silentBackup == null) {
    openSnackbar(
      SnackbarMessage(
        title: "功能已禁用".tr(),
        description: "云备份功能已被禁用，请使用本地导出功能".tr(),
        icon: appStateSettings["outlinedIcons"] == true
          ? Icons.info_outlined
          : Icons.info_rounded,
      ),
    );
  }
  return;
}

Future<void> deleteRecentBackups(context, amountToKeep,
    {bool? silentDelete}) async {
  // 云备份删除功能已禁用
  if (silentDelete == false || silentDelete == null) {
    openSnackbar(
      SnackbarMessage(
        title: "功能已禁用".tr(),
        description: "云备份删除功能已被禁用".tr(),
        icon: appStateSettings["outlinedIcons"] == true
            ? Icons.info_outlined
            : Icons.info_rounded,
      ),
    );
  }
  return;
}

Future<void> deleteBackup(dynamic driveApi, String fileId) async {
  // 云备份删除功能已禁用
  return;
}

Future<void> chooseBackup(context,
    {bool isManaging = false,
    bool isClientSync = false,
    bool hideDownloadButton = false}) async {
  try {
    openBottomSheet(
      context,
      BackupManagement(
        isManaging: isManaging,
        isClientSync: isClientSync,
        hideDownloadButton: hideDownloadButton,
      ),
    );
  } catch (e) {
    popRoute(context);
    openSnackbar(
      SnackbarMessage(
          title: e.toString(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.error_outlined
              : Icons.error_rounded),
    );
  }
}

Future<void> loadBackup(
    BuildContext context, dynamic driveApi, dynamic file) async {
  // 云备份加载功能已禁用
  openSnackbar(
    SnackbarMessage(
      title: "功能已禁用".tr(),
      description: "云备份加载功能已被禁用".tr(),
      icon: appStateSettings["outlinedIcons"] == true
          ? Icons.info_outlined
          : Icons.info_rounded,
    ),
  );
  return;
}

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
  void refreshState() {
    setState(() {});
  }

  void openPage({VoidCallback? onNext}) {
    if (widget.navigationSidebarButton) {
      pageNavigationFrameworkKey.currentState!
          .changePage(8, switchNavbar: true);
      appStateKey.currentState?.refreshAppState();
    } else {
      if (onNext != null) onNext();
    }
  }

  void loginWithSync({VoidCallback? onNext}) {
    // Google登录和同步功能已禁用
    openSnackbar(
      SnackbarMessage(
        title: "功能已禁用".tr(),
        description: "Google登录和云同步功能已被禁用".tr(),
        icon: appStateSettings["outlinedIcons"] == true
            ? Icons.info_outlined
            : Icons.info_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.navigationSidebarButton == true) {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        child: getPlatform() == PlatformOS.isIOS
            ? NavigationSidebarButton(
                key: ValueKey("disabled"),
                label: "备份已禁用".tr(),
                icon: MoreIcons.google_drive,
                iconScale: 0.87,
                onTap: () {
                  openSnackbar(
                    SnackbarMessage(
                      title: "功能已禁用".tr(),
                      description: "云备份功能已被禁用".tr(),
                      icon: appStateSettings["outlinedIcons"] == true
              ? Icons.info_outlined
              : Icons.info_rounded,
                    ),
                  );
                },
                isSelected: false,
              )
            : NavigationSidebarButton(
                key: ValueKey("disabled"),
                label: "登录已禁用".tr(),
                icon: MoreIcons.google,
                onTap: () {
                  openSnackbar(
                    SnackbarMessage(
                      title: "功能已禁用".tr(),
                      description: "Google登录功能已被禁用".tr(),
                      icon: appStateSettings["outlinedIcons"] == true
            ? Icons.info_outlined
            : Icons.info_rounded,
                    ),
                  );
                },
                isSelected: false,
              ),
      );
    }
    return getPlatform() == PlatformOS.isIOS
        ? SettingsContainerOpenPage(
            openPage: AccountsPage(),
            isOutlined: widget.isOutlinedButton,
            onTap: (openContainer) {
              openSnackbar(
                SnackbarMessage(
                  title: "功能已禁用".tr(),
                  description: "云备份功能已被禁用".tr(),
                  icon: appStateSettings["outlinedIcons"] == true
              ? Icons.info_outlined
              : Icons.info_rounded,
                ),
              );
            },
            title: widget.forceButtonName ?? "备份已禁用".tr(),
            icon: MoreIcons.google_drive,
            iconScale: 0.87,
          )
            : SettingsContainerOpenPage(
                openPage: AccountsPage(),
                isOutlined: widget.isOutlinedButton,
                onTap: (openContainer) {
                  loginWithSync(onNext: openContainer);
                },
                title: widget.forceButtonName ?? "login".tr(),
                icon: widget.forceButtonName == null
                    ? MoreIcons.google
                    : MoreIcons.google_drive,
                iconScale: widget.forceButtonName == null ? 1 : 0.87,
              )
        : getPlatform() == PlatformOS.isIOS
            ? SettingsContainerOpenPage(
                openPage: AccountsPage(),
                title: widget.forceButtonName ?? "backup".tr(),
                icon: MoreIcons.google_drive,
                isOutlined: widget.isOutlinedButton,
                iconScale: 0.87,
              )
            : SettingsContainerOpenPage(
                openPage: AccountsPage(),
                title: widget.forceButtonName ?? "用户".tr(),
                icon: widget.forceButtonName == null
                    ? appStateSettings["outlinedIcons"] == true
                        ? Icons.person_outlined
                        : Icons.person_rounded
                    : MoreIcons.google_drive,
                iconScale: widget.forceButtonName == null ? 1 : 0.87,
                isOutlined: widget.isOutlinedButton,
              );
  }
}

Future<(Map<String, dynamic>?, List<Map<String, dynamic>>?)> getDriveFiles() async {
  // Google Drive功能已禁用
  openSnackbar(
    SnackbarMessage(
      title: "功能已禁用".tr(),
      description: "Google Drive功能已被禁用".tr(),
      icon: appStateSettings["outlinedIcons"] == true
          ? Icons.info_outlined
          : Icons.info_rounded,
    ),
  );
  return (null, null);
}

class BackupManagement extends StatefulWidget {
  const BackupManagement({
    Key? key,
    required this.isManaging,
    required this.isClientSync,
    this.hideDownloadButton = false,
  }) : super(key: key);

  final bool isManaging;
  final bool isClientSync;
  final bool hideDownloadButton;

  @override
  State<BackupManagement> createState() => _BackupManagementState();
}

class _BackupManagementState extends State<BackupManagement> {
  List<Map<String, dynamic>> filesState = [];
  List<int> deletedIndices = [];
  UniqueKey dropDownKey = UniqueKey();
  bool isLoading = false;
  bool autoBackups = false;
  bool backupSync = false;

  @override
  void initState() {
    super.initState();
    // Google Drive功能已禁用，不需要初始化
    filesState = [];
  }

  @override
  Widget build(BuildContext context) {
    // Google Drive功能已禁用
    return PopupFramework(
      title: widget.isClientSync
          ? "devices".tr().capitalizeFirst
          : widget.isManaging
              ? "backups".tr()
              : "restore-a-backup".tr(),
      subtitle: "功能已禁用".tr(),
      child: Column(
        children: [
          AboutInfoBox(
            title: "功能已禁用".tr(),
            list: ["Google Drive备份功能已被禁用".tr()],
            color: appStateSettings["materialYou"] == true
                ? Theme.of(context).colorScheme.secondaryContainer
                : getColor(context, "lightDarkAccentHeavyLight"),
            padding: EdgeInsetsDirectional.only(
              start: 5,
              end: 5,
              bottom: 10,
              top: 5,
            ),
          ),
        ],
      ),
    );
  }
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
      baseColor: appStateSettings["materialYou"] == true
          ? Theme.of(context).colorScheme.secondaryContainer
          : getColor(context, "lightDarkAccentHeavyLight"),
      highlightColor: appStateSettings["materialYou"] == true
          ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2)
          : getColor(context, "lightDarkAccentHeavy").withAlpha(20),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8.0),
        child: Tappable(
          onTap: () {},
          borderRadius: 15,
          color: appStateSettings["materialYou"] == true
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
                          appStateSettings["outlinedIcons"] == true
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
                                icon: appStateSettings["outlinedIcons"] == true
                              ? Icons.close_outlined
                              : Icons.close_rounded),
                            SizedBox(width: 5),
                            ButtonIcon(
                                onTap: () {},
                                icon: appStateSettings["outlinedIcons"] == true
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

// Google Drive功能已被禁用 - saveDriveFileToDevice函数已移除
Future<bool> saveDriveFileToDevice({
  required BuildContext boxContext,
  required Map<String, dynamic> driveApi,
  required Map<String, dynamic> fileToSave,
}) async {
  print("Google Drive功能已被禁用，无法下载文件");
  return false;
}

// Google Drive功能已被禁用 - 备份提醒弹窗已移除
bool openBackupReminderPopupCheck(BuildContext context) {
  // Google Drive功能已被禁用，不再显示备份提醒弹窗
  return false;
}
