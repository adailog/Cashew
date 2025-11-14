import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/habitsPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/habits.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/heatMap.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/sliverStickyLabelDivider.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/statistics.dart';

class HabitStatsPage extends StatefulWidget {
  final Habit habit;

  const HabitStatsPage({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  State<HabitStatsPage> createState() => HabitStatsPageState();
}

class HabitStatsPageState extends State<HabitStatsPage> {
  DateTime? startDate;
  DateTime? endDate;
  bool showAllTime = true;

  @override
  void initState() {
    super.initState();
    // 默认显示最近30天的数据
    endDate = DateTime.now();
    startDate = DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "habit-stats".tr(),
      listWidgets: [
        // 日期范围选择
        SettingsContainer(
          title: showAllTime ? "all-time".tr() : "custom-range".tr(),
          icon: Icons.date_range,
          onTap: () async {
            final result = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
              initialDateRange: showAllTime
                  ? null
                  : DateTimeRange(start: startDate!, end: endDate!),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  child: child!,
                );
              },
            );

            if (result != null) {
              setState(() {
                startDate = result.start;
                endDate = result.end;
                showAllTime = false;
              });
            } else if (showAllTime == false) {
              setState(() {
                showAllTime = true;
              });
            }
          },
          description: showAllTime
              ? null
              : "${getDateString(startDate!)} - ${getDateString(endDate!)}",
        ),

        // 习惯完成率统计
        FutureBuilder<double>(
          future: _getCompletionRate(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final completionRate = snapshot.data ?? 0.0;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "completion-rate".tr(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completionRate,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionRate >= 0.8
                          ? Colors.green
                          : completionRate >= 0.5
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextFont(
                        text: "${(completionRate * 100).toStringAsFixed(1)}%",
                        fontSize: 16,
                      ),
                      TextFont(
                        text: showAllTime
                            ? "all-time".tr()
                            : "last-${DateTime.now().difference(startDate!).inDays}-days"
                                .tr(),
                        fontSize: 14,
                        textColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        // 连续打卡统计
        FutureBuilder<int>(
          future: _getCurrentStreak(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentStreak = snapshot.data ?? 0;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "current-streak".tr(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFont(
                              text: currentStreak.toString(),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              textColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            TextFont(
                              text: currentStreak == 1
                                  ? "day".tr()
                                  : "days".tr(),
                              fontSize: 14,
                              textColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 最长连续打卡记录
        FutureBuilder<int>(
          future: _getLongestStreak(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final longestStreak = snapshot.data ?? 0;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "longest-streak".tr(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFont(
                              text: longestStreak.toString(),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              textColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            TextFont(
                              text: longestStreak == 1
                                  ? "day".tr()
                                  : "days".tr(),
                              fontSize: 14,
                              textColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 习惯完成热力图
        FutureBuilder<List<HabitRecord>>(
          future: _getHabitRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "completion-heatmap".tr(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  HabitHeatMap(
                    records: records,
                    habit: widget.habit,
                    startDate: showAllTime
                        ? DateTime.now().subtract(const Duration(days: 365))
                        : startDate!,
                    endDate: showAllTime
                        ? DateTime.now()
                        : endDate!,
                  ),
                ],
              ),
            );
          },
        ),

        // 每周完成情况
        FutureBuilder<Map<String, int>>(
          future: _getWeeklyCompletion(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final weeklyData = snapshot.data ?? {};
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "weekly-completion".tr(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: WeeklyBarChart(
                      weeklyData: weeklyData,
                      color: widget.habit.color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 获取习惯完成率
  Future<double> _getCompletionRate() async {
    final dbHelper = HabitsDatabaseHelper();
    final records = await dbHelper.getHabitRecords(
      widget.habit.habitPk,
      startDate: showAllTime ? null : startDate,
      endDate: showAllTime ? null : endDate,
    );

    if (records.isEmpty) return 0.0;

    // 计算总天数
    final totalDays = showAllTime
        ? DateTime.now().difference(widget.habit.createdAt).inDays + 1
        : endDate!.difference(startDate!).inDays + 1;

    // 计算完成天数
    final completedDays = records.length;

    return completedDays / totalDays;
  }

  // 获取当前连续打卡天数
  Future<int> _getCurrentStreak() async {
    final dbHelper = HabitsDatabaseHelper();
    return await dbHelper.getCurrentStreak(widget.habit.habitPk);
  }

  // 获取最长连续打卡天数
  Future<int> _getLongestStreak() async {
    final dbHelper = HabitsDatabaseHelper();
    return await dbHelper.getLongestStreak(widget.habit.habitPk);
  }

  // 获取习惯记录
  Future<List<HabitRecord>> _getHabitRecords() async {
    final dbHelper = HabitsDatabaseHelper();
    return await dbHelper.getHabitRecords(
      widget.habit.habitPk,
      startDate: showAllTime
          ? DateTime.now().subtract(const Duration(days: 365))
          : startDate,
      endDate: showAllTime ? DateTime.now() : endDate,
    );
  }

  // 获取每周完成情况
  Future<Map<String, int>> _getWeeklyCompletion() async {
    final dbHelper = HabitsDatabaseHelper();
    return await dbHelper.getWeeklyCompletion(widget.habit.habitPk);
  }
}

// 习惯热力图组件
class HabitHeatMap extends StatelessWidget {
  final List<HabitRecord> records;
  final Habit habit;
  final DateTime startDate;
  final DateTime endDate;

  const HabitHeatMap({
    Key? key,
    required this.records,
    required this.habit,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 创建记录日期的集合，便于快速查找
    final recordDates = <DateTime>{};
    for (final record in records) {
      recordDates.add(DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      ));
    }

    // 计算总天数
    final totalDays = endDate.difference(startDate).inDays + 1;

    // 如果天数太多，限制为一年
    final displayStartDate = totalDays > 365
        ? endDate.subtract(const Duration(days: 365))
        : startDate;
    final displayTotalDays = endDate.difference(displayStartDate).inDays + 1;

    // 计算网格大小
    final weeksCount = (displayTotalDays / 7).ceil();
    final cellSize = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月份标签
        SizedBox(
          height: 20,
          child: Row(
            children: [
              const SizedBox(width: 30), // 为星期标签留空间
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getMonthLabels(displayStartDate, endDate),
                ),
              ),
            ],
          ),
        ),
        // 热力图网格
        SizedBox(
          height: (weeksCount + 1) * (cellSize + 2), // +1 为星期标签留空间
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 星期标签
              Column(
                children: [
                  const SizedBox(height: cellSize + 2), // 与月份标签对齐
                  ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return SizedBox(
                      height: cellSize,
                      width: 20,
                      child: Center(
                        child: TextFont(
                          text: day,
                          fontSize: 8,
                          textColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              // 热力图格子
              Expanded(
                child: Column(
                  children: List.generate(weeksCount, (weekIndex) {
                    return SizedBox(
                      height: cellSize + 2,
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final currentDate = displayStartDate.add(
                            Duration(days: weekIndex * 7 + dayIndex),
                          );

                          // 如果当前日期超出了结束日期，显示空格子
                          if (currentDate.isAfter(endDate)) {
                            return SizedBox(
                              width: cellSize,
                              height: cellSize,
                            );
                          }

                          final isCompleted = recordDates.contains(
                            DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                            ),
                          );

                          return Container(
                            width: cellSize,
                            height: cellSize,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? getColor(context, habit.color)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFont(
              text: "less".tr(),
              fontSize: 10,
              textColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.7),
            ),
            const SizedBox(width: 5),
            ...[0.3, 0.5, 0.7, 1.0].map((opacity) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: getColor(context, habit.color).withOpacity(opacity),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }).toList(),
            const SizedBox(width: 5),
            TextFont(
              text: "more".tr(),
              fontSize: 10,
              textColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.7),
            ),
          ],
        ),
      ],
    );
  }

  // 获取月份标签
  List<Widget> _getMonthLabels(DateTime start, DateTime end) {
    final labels = <Widget>[];
    var current = DateTime(start.year, start.month, 1);
    final endMonth = DateTime(end.year, end.month, 1);

    while (current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
      final weekPosition = (current.difference(start).inDays / 7).floor();
      final weekWidth = (1.0 / (end.difference(start).inDays / 7).ceil());

      if (weekPosition >= 0) {
        labels.add(
          SizedBox(
            width: 0,
            child: TextFont(
              text: _getMonthAbbreviation(current.month),
              fontSize: 10,
              textColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.7),
            ),
          ),
        );
      }

      current = DateTime(current.year, current.month + 1, 1);
    }

    return labels;
  }

  // 获取月份缩写
  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// 每周完成情况柱状图
class WeeklyBarChart extends StatelessWidget {
  final Map<String, int> weeklyData;
  final String color;

  const WeeklyBarChart({
    Key? key,
    required this.weeklyData,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekDays = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];

    // 找出最大值，用于计算比例
    final maxValue = weeklyData.values.isEmpty
        ? 1
        : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weekDays.map((day) {
        final value = weeklyData[day] ?? 0;
        final height = maxValue > 0 ? (value / maxValue) * 150 : 0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFont(
                    text: value.toString(),
                    fontSize: 12,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      color: getColor(context, color),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 30,
              child: TextFont(
                text: day.tr().substring(0, 1),
                fontSize: 10,
                textAlign: TextAlign.center,
                textColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
