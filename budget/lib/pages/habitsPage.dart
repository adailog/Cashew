import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/habits.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/animatedNumber.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({Key? key}) : super(key: key);

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  List<HabitWithRecords> habitsWithRecords = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final habits = await HabitsDatabaseHelper.getAllHabitsWithRecords();
      setState(() {
        habitsWithRecords = habits;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading habits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "习惯打卡",
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            openBottomSheet(
              context,
              PopupFramework(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFont(
                        text: "关于习惯打卡",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 16),
                      TextFont(
                        text: "习惯打卡功能可以帮助您养成良好习惯。您可以创建日常习惯，每天进行打卡，记录您的进步。",
                        fontSize: 16,
                      ),
                      SizedBox(height: 16),
                      TextFont(
                        text: "支持两种类型的习惯：",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8),
                      TextFont(
                        text: "• 是/否类型：例如"早起"、"运动"等，只需标记完成或未完成\n• 数值类型：例如"喝水"、"阅读"等，可以记录具体数值",
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
      floatingActionButton: Fab(
        openPage: AddHabitPage(
          onHabitAdded: _loadHabits,
        ),
        icon: Icons.add,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : habitsWithRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      TextFont(
                        text: "还没有习惯",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8),
                      TextFont(
                        text: "点击右下角的 + 按钮创建您的第一个习惯",
                        fontSize: 16,
                        textColor: getColor(context, "textLight"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHabits,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 100 + getBottomPadding(context),
                    ),
                    itemCount: habitsWithRecords.length,
                    itemBuilder: (context, index) {
                      final habitWithRecords = habitsWithRecords[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: HabitCard(
                              habitWithRecords: habitWithRecords,
                              onHabitUpdated: _loadHabits,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class HabitCard extends StatefulWidget {
  final HabitWithRecords habitWithRecords;
  final VoidCallback onHabitUpdated;

  const HabitCard({
    Key? key,
    required this.habitWithRecords,
    required this.onHabitUpdated,
  }) : super(key: key);

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool isCheckingIn = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitWithRecords.habit;
    final isCompletedToday = widget.habitWithRecords.isCompletedToday();
    final streakDays = widget.habitWithRecords.getStreakDays();
    final todayRecord = widget.habitWithRecords.getRecordForDate(DateTime.now());
    
    Color cardColor = habit.colour != null && habit.colour!.isNotEmpty
        ? HexColor(habit.colour!)
        : Theme.of(context).colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Tappable(
        onTap: () {
          openBottomSheet(
            context,
            HabitDetailPage(
              habitWithRecords: widget.habitWithRecords,
              onHabitUpdated: widget.onHabitUpdated,
            ),
          );
        },
        borderRadius: 15,
        color: getColor(context, "lightDarkAccent"),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: cardColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 习惯图标/颜色
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: habit.emojiIconName != null && habit.emojiIconName!.isNotEmpty
                          ? Text(
                              habit.emojiIconName!,
                              style: TextStyle(fontSize: 28),
                            )
                          : Icon(
                              habit.iconName != null ? getIconData(habit.iconName!) : Icons.check_circle,
                              color: cardColor,
                              size: 28,
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFont(
                          text: habit.name,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        if (habit.question.isNotEmpty)
                          TextFont(
                            text: habit.question,
                            fontSize: 14,
                            textColor: getColor(context, "textLight"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // 连续打卡天数
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: cardColor,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        TextFont(
                          text: "$streakDays",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 打卡按钮区域
              if (habit.type == HabitType.yesNo)
                Row(
                  children: [
                    Expanded(
                      child: Tappable(
                        onTap: isCheckingIn ? null : () async {
                          setState(() {
                            isCheckingIn = true;
                          });
                          
                          try {
                            await HabitsDatabaseHelper.toggleHabitCompletion(
                              habit.habitPk,
                              DateTime.now(),
                            );
                            widget.onHabitUpdated();
                          } catch (e) {
                            print('Error toggling habit: $e');
                          } finally {
                            setState(() {
                              isCheckingIn = false;
                            });
                          }
                        },
                        color: isCompletedToday
                            ? cardColor
                            : Colors.transparent,
                        borderRadius: 12,
                        border: Border.all(
                          color: cardColor,
                          width: 1.5,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: isCheckingIn
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isCompletedToday ? Icons.check : Icons.add,
                                        color: isCompletedToday ? Colors.white : cardColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      TextFont(
                                        text: isCompletedToday ? "已完成" : "打卡",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        textColor: isCompletedToday ? Colors.white : cardColor,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Tappable(
                        onTap: () {
                          openBottomSheet(
                            context,
                            NumericalHabitCheckInPage(
                              habit: habit,
                              todayRecord: todayRecord,
                              onHabitUpdated: widget.onHabitUpdated,
                            ),
                          );
                        },
                        color: todayRecord != null
                            ? cardColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: 12,
                        border: Border.all(
                          color: cardColor,
                          width: 1.5,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: cardColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                TextFont(
                                  text: todayRecord != null
                                      ? "${todayRecord.value} ${habit.unit ?? ''}"
                                      : "记录数值",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  textColor: cardColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
