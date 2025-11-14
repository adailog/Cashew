import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/habits.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitNumericalCheckInPage extends StatefulWidget {
  final HabitWithRecords habitWithRecords;

  const HabitNumericalCheckInPage({
    Key? key,
    required this.habitWithRecords,
  }) : super(key: key);

  @override
  State<HabitNumericalCheckInPage> createState() => _HabitNumericalCheckInPageState();
}

class _HabitNumericalCheckInPageState extends State<HabitNumericalCheckInPage> {
  final _valueController = TextEditingController();
  bool _isLoading = false;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    // 检查今天是否已经打卡
    final todayRecord = widget.habitWithRecords.records.firstWhereOrNull(
      (record) => isSameDay(record.date, DateTime.now()),
    );
    if (todayRecord != null) {
      _currentValue = todayRecord.value;
      _valueController.text = todayRecord.value.toString();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitWithRecords.habit;
    
    return PageFramework(
      title: "数值打卡",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveCheckIn,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.check),
        label: TextFont(
          text: "完成打卡",
          textColor: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 习惯信息
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: getColor(context, "lightDarkAccent"),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HexColor(habit.colour).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getIconData(habit.iconName),
                      color: HexColor(habit.colour),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFont(
                          text: habit.name,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 4),
                        TextFont(
                          text: habit.question,
                          fontSize: 16,
                          textColor: getColor(context, "textLight"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // 目标信息
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: getColor(context, "lightDarkAccent"),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "今日目标",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8),
                  TextFont(
                    text: "${habit.targetType == HabitTargetType.atLeast ? '至少' : '至多'} ${habit.targetValue} ${habit.unit ?? ''}",
                    fontSize: 16,
                  ),
                  SizedBox(height: 12),
                  // 进度条
                  LinearProgressIndicator(
                    value: _getProgress(),
                    backgroundColor: getColor(context, "canvas"),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      HexColor(habit.colour),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextFont(
                        text: "0 ${habit.unit ?? ''}",
                        fontSize: 12,
                        textColor: getColor(context, "textLight"),
                      ),
                      TextFont(
                        text: "${(habit.targetValue * 1.5).toStringAsFixed(0)} ${habit.unit ?? ''}",
                        fontSize: 12,
                        textColor: getColor(context, "textLight"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // 数值输入
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: getColor(context, "lightDarkAccent"),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: "输入数值",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "数值",
                      hintText: "请输入今日完成的数值",
                      suffixText: habit.unit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentValue = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // 快速选择按钮
                  TextFont(
                    text: "快速选择",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildQuickSelectButtons(habit),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // 完成状态
            if (_currentValue > 0)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isGoalMet()
                      ? HexColor(habit.colour).withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isGoalMet()
                        ? HexColor(habit.colour)
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isGoalMet() ? Icons.check_circle : Icons.info,
                      color: _isGoalMet()
                          ? HexColor(habit.colour)
                          : getColor(context, "textLight"),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFont(
                        text: _isGoalMet()
                            ? "太棒了！今日目标已完成！"
                            : "继续努力，距离目标还差 ${_getRemainingValue().toStringAsFixed(1)} ${habit.unit ?? ''}",
                        fontSize: 16,
                        textColor: _isGoalMet()
                            ? HexColor(habit.colour)
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuickSelectButtons(Habit habit) {
    final List<Widget> buttons = [];
    final targetValue = habit.targetValue;
    final unit = habit.unit ?? "";
    
    // 根据目标值生成快速选择按钮
    if (targetValue <= 5) {
      // 小目标，按0.5递增
      for (double i = 0.5; i <= targetValue * 1.5; i += 0.5) {
        buttons.add(_buildQuickSelectButton(i, "${i.toStringAsFixed(1)} $unit"));
      }
    } else if (targetValue <= 20) {
      // 中等目标，按1递增
      for (double i = 1; i <= targetValue * 1.5; i += 1) {
        buttons.add(_buildQuickSelectButton(i, "${i.toStringAsFixed(0)} $unit"));
      }
    } else {
      // 大目标，按目标值的1/4递增
      final step = targetValue / 4;
      for (int i = 1; i <= 6; i++) {
        final value = step * i;
        buttons.add(_buildQuickSelectButton(value, "${value.toStringAsFixed(0)} $unit"));
      }
    }
    
    return buttons;
  }

  Widget _buildQuickSelectButton(double value, String label) {
    return Tappable(
      onTap: () {
        setState(() {
          _currentValue = value;
          _valueController.text = value.toString();
        });
      },
      color: _currentValue == value
          ? HexColor(widget.habitWithRecords.habit.colour).withOpacity(0.2)
          : Colors.transparent,
      borderRadius: 20,
      border: Border.all(
        color: _currentValue == value
            ? HexColor(widget.habitWithRecords.habit.colour)
            : getColor(context, "lightDarkAccent"),
        width: 1.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextFont(
          text: label,
          fontSize: 14,
          textColor: _currentValue == value
              ? HexColor(widget.habitWithRecords.habit.colour)
              : getColor(context, "textLight"),
        ),
      ),
    );
  }

  double _getProgress() {
    final habit = widget.habitWithRecords.habit;
    final progress = _currentValue / habit.targetValue;
    // 限制进度在0到1之间，但允许超过100%的显示
    return progress.clamp(0.0, 1.0);
  }

  bool _isGoalMet() {
    final habit = widget.habitWithRecords.habit;
    if (habit.targetType == HabitTargetType.atLeast) {
      return _currentValue >= habit.targetValue;
    } else {
      return _currentValue <= habit.targetValue && _currentValue > 0;
    }
  }

  double _getRemainingValue() {
    final habit = widget.habitWithRecords.habit;
    if (habit.targetType == HabitTargetType.atLeast) {
      return (habit.targetValue - _currentValue).clamp(0.0, double.infinity);
    } else {
      return (_currentValue - habit.targetValue).clamp(0.0, double.infinity);
    }
  }

  Future<void> _saveCheckIn() async {
    if (_valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入数值'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入有效的数字'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 检查今天是否已经打卡
      final todayRecord = widget.habitWithRecords.records.firstWhereOrNull(
        (record) => isSameDay(record.date, DateTime.now()),
      );

      if (todayRecord != null) {
        // 更新今天的打卡记录
        await HabitsDatabaseHelper.updateRecord(
          recordPk: todayRecord.recordPk,
          value: value,
        );
      } else {
        // 创建新的打卡记录
        await HabitsDatabaseHelper.createRecord(
          habitFk: widget.habitWithRecords.habit.habitPk,
          date: DateTime.now(),
          value: value,
        );
      }

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isGoalMet() ? '打卡成功！目标已完成！' : '打卡成功！'),
          backgroundColor: _isGoalMet() ? Colors.green : Colors.blue,
        ),
      );

      // 返回上一页
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving check-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('打卡失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
