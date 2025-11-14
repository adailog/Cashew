import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

// 习惯模型类
class HabitWithRecords {
  final Habit habit;
  final List<HabitRecord> records;
  
  HabitWithRecords({
    required this.habit,
    required this.records,
  });
  
  // 获取指定日期的打卡记录
  HabitRecord? getRecordForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    try {
      return records.firstWhere(
        (record) => 
          DateTime(record.date.year, record.date.month, record.date.day) == dateOnly,
      );
    } catch (e) {
      return null;
    }
  }
  
  // 检查今天是否已完成
  bool isCompletedToday() {
    final today = DateTime.now();
    final todayRecord = getRecordForDate(today);
    
    if (habit.type == HabitType.yesNo) {
      return todayRecord?.value == 1.0;
    } else {
      // 数值类型习惯
      if (todayRecord == null) return false;
      
      switch (habit.targetType) {
        case HabitTargetType.atLeast:
          return todayRecord.value >= habit.targetValue;
        case HabitTargetType.atMost:
          return todayRecord.value <= habit.targetValue;
      }
    }
  }
  
  // 获取连续完成天数
  int getStreakDays() {
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    while (true) {
      final record = getRecordForDate(currentDate);
      bool completed = false;
      
      if (record != null) {
        if (habit.type == HabitType.yesNo) {
          completed = record.value == 1.0;
        } else {
          switch (habit.targetType) {
            case HabitTargetType.atLeast:
              completed = record.value >= habit.targetValue;
              break;
            case HabitTargetType.atMost:
              completed = record.value <= habit.targetValue;
              break;
          }
        }
      }
      
      if (!completed) break;
      
      streak++;
      currentDate = currentDate.subtract(Duration(days: 1));
    }
    
    return streak;
  }
}

// 习惯数据库操作类
class HabitsDatabaseHelper {
  
  // 获取所有习惯
  static Future<List<Habit>> getAllHabits() async {
    return await databaseInstance.database.allHabits;
  }
  
  // 获取所有习惯（包含记录）
  static Future<List<HabitWithRecords>> getAllHabitsWithRecords() async {
    final habits = await getAllHabits();
    final habitsWithRecords = <HabitWithRecords>[];
    
    for (final habit in habits) {
      final records = await getHabitRecords(habit.habitPk);
      habitsWithRecords.add(HabitWithRecords(
        habit: habit,
        records: records,
      ));
    }
    
    return habitsWithRecords;
  }
  
  // 获取习惯记录
  static Future<List<HabitRecord>> getHabitRecords(String habitPk) async {
    final query = databaseInstance.database.select(databaseInstance.database.habitRecords)
      ..where((record) => record.habitFk.equals(habitPk))
      ..orderBy([(record) => drift.OrderingTerm.desc(record.date)]);
    
    return await query.get();
  }
  
  // 创建习惯
  static Future<Habit> createHabit({
    required String name,
    String? description,
    String? question,
    String? colour,
    String? iconName,
    String? emojiIconName,
    HabitFrequency frequency = HabitFrequency.daily,
    HabitType type = HabitType.yesNo,
    HabitTargetType targetType = HabitTargetType.atLeast,
    double targetValue = 0.0,
    String? unit,
    int order = 0,
  }) async {
    final habit = HabitsCompanion.insert(
      name: name,
      description: drift.Value(description),
      question: drift.Value(question),
      colour: drift.Value(colour),
      iconName: drift.Value(iconName),
      emojiIconName: drift.Value(emojiIconName),
      frequency: frequency,
      type: type,
      targetType: targetType,
      targetValue: targetValue,
      unit: drift.Value(unit),
      order: order,
    );
    
    final habitPk = await databaseInstance.database.into(databaseInstance.database.habits).insert(habit);
    return await (databaseInstance.database.select(databaseInstance.database.habits)
      ..where((h) => h.habitPk.equals(habitPk))).getSingle();
  }
  
  // 更新习惯
  static Future<void> updateHabit(Habit habit) async {
    await databaseInstance.database.update(databaseInstance.database.habits).replace(habit);
  }
  
  // 删除习惯
  static Future<void> deleteHabit(String habitPk) async {
    // 先删除相关记录
    await (databaseInstance.database.delete(databaseInstance.database.habitRecords)
      ..where((record) => record.habitFk.equals(habitPk))).go();
    
    // 删除习惯
    await (databaseInstance.database.delete(databaseInstance.database.habits)
      ..where((habit) => habit.habitPk.equals(habitPk))).go();
  }
  
  // 创建习惯记录（打卡）
  static Future<HabitRecord> createHabitRecord({
    required String habitFk,
    required DateTime date,
    double value = 1.0,
    String? note,
  }) async {
    // 先检查是否已有该日期的记录
    final existingQuery = databaseInstance.database.select(databaseInstance.database.habitRecords)
      ..where((record) => record.habitFk.equals(habitFk))
      ..where((record) => record.date.equals(date));
    
    final existing = await existingQuery.get();
    
    if (existing.isNotEmpty) {
      // 更新现有记录
      final updatedRecord = existing.first.copyWith(
        value: value,
        note: drift.Value(note),
        dateTimeModified: DateTime.now(),
      );
      await databaseInstance.database.update(databaseInstance.database.habitRecords).replace(updatedRecord);
      return updatedRecord;
    } else {
      // 创建新记录
      final record = HabitRecordsCompanion.insert(
        habitFk: habitFk,
        date: date,
        value: value,
        note: drift.Value(note),
      );
      
      final recordPk = await databaseInstance.database.into(databaseInstance.database.habitRecords).insert(record);
      return await (databaseInstance.database.select(databaseInstance.database.habitRecords)
        ..where((r) => r.recordPk.equals(recordPk))).getSingle();
    }
  }
  
  // 删除习惯记录
  static Future<void> deleteHabitRecord(String recordPk) async {
    await (databaseInstance.database.delete(databaseInstance.database.habitRecords)
      ..where((record) => record.recordPk.equals(recordPk))).go();
  }
  
  // 获取指定日期的习惯记录
  static Future<HabitRecord?> getHabitRecordForDate(String habitFk, DateTime date) async {
    final query = databaseInstance.database.select(databaseInstance.database.habitRecords)
      ..where((record) => record.habitFk.equals(habitFk))
      ..where((record) => record.date.equals(date));
    
    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }
  
  // 切换习惯完成状态（用于是/否类型习惯）
  static Future<HabitRecord?> toggleHabitCompletion(String habitFk, DateTime date) async {
    final existingRecord = await getHabitRecordForDate(habitFk, date);
    
    if (existingRecord != null) {
      // 如果已有记录且为完成状态，则删除记录
      if (existingRecord.value == 1.0) {
        await deleteHabitRecord(existingRecord.recordPk);
        return null;
      } else {
        // 更新为完成状态
        return await createHabitRecord(
          habitFk: habitFk,
          date: date,
          value: 1.0,
        );
      }
    } else {
      // 创建完成记录
      return await createHabitRecord(
        habitFk: habitFk,
        date: date,
        value: 1.0,
      );
    }
  }

  // 获取当前连续打卡天数
  static Future<int> getCurrentStreak(String habitPk) async {
    final database = databaseInstance.database;
    
    // 获取最近的打卡记录
    final List<Map<String, dynamic>> maps = await database.customSelect(
      '''SELECT date FROM habit_records 
         WHERE habit_fk = :habitPk AND value >= 1.0 
         ORDER BY date DESC 
         LIMIT 100''',
      variables: drift.Variables({'habitPk': habitPk}),
      readsFrom: {database.habitRecords},
    ).get();
    
    if (maps.isEmpty) return 0;
    
    int streak = 0;
    DateTime? previousDate;
    
    for (final map in maps) {
      final currentDate = DateTime.parse(map['date']);
      
      if (previousDate == null) {
        // 检查今天是否已打卡
        final today = DateTime.now();
        if (currentDate.year == today.year &&
            currentDate.month == today.month &&
            currentDate.day == today.day) {
          streak = 1;
          previousDate = currentDate;
        } else {
          // 检查昨天是否已打卡
          final yesterday = today.subtract(const Duration(days: 1));
          if (currentDate.year == yesterday.year &&
              currentDate.month == yesterday.month &&
              currentDate.day == yesterday.day) {
            streak = 1;
            previousDate = currentDate;
          } else {
            break; // 没有连续打卡
          }
        }
      } else {
        // 检查是否连续
        final expectedDate = previousDate.subtract(const Duration(days: 1));
        if (currentDate.year == expectedDate.year &&
            currentDate.month == expectedDate.month &&
            currentDate.day == expectedDate.day) {
          streak++;
          previousDate = currentDate;
        } else {
          break; // 连续中断
        }
      }
    }
    
    return streak;
  }

  // 获取最长连续打卡天数
  static Future<int> getLongestStreak(String habitPk) async {
    final database = databaseInstance.database;
    
    // 获取所有打卡记录
    final List<Map<String, dynamic>> maps = await database.customSelect(
      '''SELECT date FROM habit_records 
         WHERE habit_fk = :habitPk AND value >= 1.0 
         ORDER BY date ASC''',
      variables: drift.Variables({'habitPk': habitPk}),
      readsFrom: {database.habitRecords},
    ).get();
    
    if (maps.isEmpty) return 0;
    
    int maxStreak = 0;
    int currentStreak = 1;
    DateTime? previousDate;
    
    for (final map in maps) {
      final currentDate = DateTime.parse(map['date']);
      
      if (previousDate == null) {
        previousDate = currentDate;
        maxStreak = 1;
      } else {
        final expectedDate = previousDate.add(const Duration(days: 1));
        if (currentDate.year == expectedDate.year &&
            currentDate.month == expectedDate.month &&
            currentDate.day == expectedDate.day) {
          currentStreak++;
        } else {
          maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
          currentStreak = 1;
        }
        previousDate = currentDate;
      }
    }
    
    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  // 获取每周完成情况
  static Future<Map<String, int>> getWeeklyCompletion(String habitPk) async {
    final database = databaseInstance.database;
    
    // 获取最近7天的打卡记录
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    
    final List<Map<String, dynamic>> maps = await database.customSelect(
      '''SELECT date, COUNT(*) as count FROM habit_records 
         WHERE habit_fk = :habitPk AND value >= 1.0 
         AND date >= :startDate AND date <= :endDate
         GROUP BY date
         ORDER BY date ASC''',
      variables: drift.Variables({
        'habitPk': habitPk,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      }),
      readsFrom: {database.habitRecords},
    ).get();
    
    final weekDays = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];
    
    final result = <String, int>{};
    
    // 初始化所有工作日为0
    for (final day in weekDays) {
      result[day] = 0;
    }
    
    // 填充实际数据
    for (final map in maps) {
      final date = DateTime.parse(map['date']);
      final dayOfWeek = date.weekday - 1; // Monday = 0
      if (dayOfWeek >= 0 && dayOfWeek < 7) {
        result[weekDays[dayOfWeek]] = map['count'] as int;
      }
    }
    
    return result;
  }
}
