import 'package:flutter/material.dart';
import 'package:budget/struct/initializeNotifications.dart';

/// 初始化通知服务的组件
class InitializeNotificationService extends StatefulWidget {
  final Widget child;

  const InitializeNotificationService({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<InitializeNotificationService> createState() => _InitializeNotificationServiceState();
}

class _InitializeNotificationServiceState extends State<InitializeNotificationService> {
  @override
  void initState() {
    super.initState();
    // 在这里可以添加初始化通知服务的逻辑
    _initializeNotificationService();
  }

  void _initializeNotificationService() async {
    // 初始化通知服务
    try {
      await initializeNotifications();
    } catch (e) {
      print("初始化通知服务失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
