import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/habits.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/colorPicker.dart';
import 'package:budget/widgets/iconPicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:collection/collection.dart';
import 'habitStatsPage.dart';

class HabitDetailsPage extends StatefulWidget {
  final HabitWithRecords habitWithRecords;

  const HabitDetailsPage({
    Key? key,
    required this.habitWithRecords,
  }) : super(key: key);

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  late HabitWithRecords _habitWithRecords;
  bool _isLoading = false;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();
  
  late HabitType _selectedType;
  late HabitFrequency _selectedFrequency;
  late HabitTargetType _selectedTargetType;
  late String _selectedColor;
  late String _selectedIcon;
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _habitWithRecords = widget.habitWithRecords;
    _initializeControllers();
  }

  void _initializeControllers() {
    final habit = _habitWithRecords.habit;
    
    _nameController.text = habit.name;
    _descriptionController.text = habit.description ?? "";
    _questionController.text = habit.question;
    _targetValueController.text = habit.targetValue.toString();
    _unitController.text = habit.unit ?? "";
    
    _selectedType = habit.type;
    _selectedFrequency = habit.frequency;
    _selectedTargetType = habit.targetType;
    _selectedColor = habit.colour;
    _selectedIcon = habit.iconName;
    _selectedEmoji = habit.emojiIconName ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habit = _habitWithRecords.habit;
    final records = _habitWithRecords.records;
    
    return PageFramework(
      title: _isEditing ? "编辑习惯" : "习惯详情",
      actions: [
        if (!_isEditing)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        if (_isEditing)
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                _isEditing = false;
                _initializeControllers();
              });
            },
          ),
        if (_isEditing)
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _updateHabit,
          ),
        if (!_isEditing)
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteHabit,
          ),
      ],
      body: _isEditing ? _buildEditForm() : _buildDetailsView(),
    );
  }

  Widget _buildDetailsView() {
    final habit = _habitWithRecords.habit;
    final records = _habitWithRecords.records;
    
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 习惯基本信息
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: getColor(context, "lightDarkAccent"),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 4),
                        TextFont(
                          text: _getFrequencyText(habit.frequency),
                          fontSize: 14,
                          textColor: getColor(context, "textLight"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (habit.description != null && habit.description!.isNotEmpty) ...[
                TextFont(
                  text: "描述",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4),
                TextFont(
                  text: habit.description!,
                  fontSize: 16,
                ),
                SizedBox(height: 16),
              ],
              TextFont(
                text: "打卡问题",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 4),
              TextFont(
                text: habit.question,
                fontSize: 16,
              ),
              if (habit.type == HabitType.numerical) ...[
                SizedBox(height: 16),
                TextFont(
                  text: "目标",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4),
                TextFont(
                  text: "${habit.targetType == HabitTargetType.atLeast ? '至少' : '至多'} ${habit.targetValue} ${habit.unit ?? ''}",
                  fontSize: 16,
                ),
              ],
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // 统计信息
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: getColor(context, "lightDarkAccent"),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFont(
                    text: "统计信息",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    icon: Icon(Icons.analytics),
                    onPressed: () {
                      pushRoute(
                        context,
                        HabitStatsPage(habit: _habitWithRecords.habit),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "连续打卡",
                      _habitWithRecords.currentStreak.toString(),
                      "天",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "最长连续",
                      _habitWithRecords.longestStreak.toString(),
                      "天",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "总打卡次数",
                      records.length.toString(),
                      "次",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "完成率",
                      "${(_getCompletionRate() * 100).toStringAsFixed(1)}%",
                      "",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // 最近打卡记录
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
                text: "最近打卡记录",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12),
              if (records.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: TextFont(
                      text: "暂无打卡记录",
                      textColor: getColor(context, "textLight"),
                    ),
                  ),
                ),
              if (records.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: records.length > 10 ? 10 : records.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: getColor(context, "textLight").withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HexColor(habit.colour).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: HexColor(habit.colour),
                          size: 20,
                        ),
                      ),
                      title: TextFont(
                        text: habit.type == HabitType.numerical
                            ? "${record.value} ${habit.unit ?? ''}"
                            : "已完成",
                      ),
                      subtitle: TextFont(
                        text: getDateString(record.date, includeTime: false),
                        fontSize: 12,
                        textColor: getColor(context, "textLight"),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () => _deleteRecord(record),
                      ),
                    );
                  },
                ),
              if (records.length > 10)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: TextFont(
                      text: "显示最近10条记录",
                      fontSize: 12,
                      textColor: getColor(context, "textLight"),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: getColor(context, "canvas"),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: title,
            fontSize: 12,
            textColor: getColor(context, "textLight"),
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFont(
                text: value,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 4),
                TextFont(
                  text: unit,
                  fontSize: 14,
                  textColor: getColor(context, "textLight"),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 习惯名称
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "习惯名称",
              hintText: "例如：早起、喝水、运动",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入习惯名称';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          // 习惯描述
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "描述（可选）",
              hintText: "描述这个习惯的目标和意义",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          
          // 习惯问题
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: "打卡问题",
              hintText: "例如：今天早起了吗？",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入打卡问题';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          // 习惯类型
          TextFont(
            text: "习惯类型",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Tappable(
                  onTap: () {
                    setState(() {
                      _selectedType = HabitType.yesNo;
                    });
                  },
                  color: _selectedType == HabitType.yesNo
                      ? getColor(context, "lightDarkAccent")
                      : Colors.transparent,
                  borderRadius: 12,
                  border: Border.all(
                    color: _selectedType == HabitType.yesNo
                        ? getColor(context, "accent")
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextFont(
                        text: "是/否类型",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: _selectedType == HabitType.yesNo
                            ? getColor(context, "accent")
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Tappable(
                  onTap: () {
                    setState(() {
                      _selectedType = HabitType.numerical;
                    });
                  },
                  color: _selectedType == HabitType.numerical
                      ? getColor(context, "lightDarkAccent")
                      : Colors.transparent,
                  borderRadius: 12,
                  border: Border.all(
                    color: _selectedType == HabitType.numerical
                        ? getColor(context, "accent")
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextFont(
                        text: "数值类型",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: _selectedType == HabitType.numerical
                            ? getColor(context, "accent")
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // 数值类型习惯的额外设置
          if (_selectedType == HabitType.numerical) ...[
            // 目标类型
            TextFont(
              text: "目标类型",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Tappable(
                    onTap: () {
                      setState(() {
                        _selectedTargetType = HabitTargetType.atLeast;
                      });
                    },
                    color: _selectedTargetType == HabitTargetType.atLeast
                        ? getColor(context, "lightDarkAccent")
                        : Colors.transparent,
                    borderRadius: 12,
                    border: Border.all(
                      color: _selectedTargetType == HabitTargetType.atLeast
                          ? getColor(context, "accent")
                          : getColor(context, "lightDarkAccent"),
                      width: 1.5,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: TextFont(
                          text: "至少",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          textColor: _selectedTargetType == HabitTargetType.atLeast
                              ? getColor(context, "accent")
                              : getColor(context, "textLight"),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Tappable(
                    onTap: () {
                      setState(() {
                        _selectedTargetType = HabitTargetType.atMost;
                      });
                    },
                    color: _selectedTargetType == HabitTargetType.atMost
                        ? getColor(context, "lightDarkAccent")
                        : Colors.transparent,
                    borderRadius: 12,
                    border: Border.all(
                      color: _selectedTargetType == HabitTargetType.atMost
                          ? getColor(context, "accent")
                          : getColor(context, "lightDarkAccent"),
                      width: 1.5,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: TextFont(
                          text: "至多",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          textColor: _selectedTargetType == HabitTargetType.atMost
                              ? getColor(context, "accent")
                              : getColor(context, "textLight"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 目标值
            TextFormField(
              controller: _targetValueController,
              decoration: InputDecoration(
                labelText: "目标值",
                hintText: "例如：8（表示8杯水）",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_selectedType == HabitType.numerical) {
                  if (value == null || value.isEmpty) {
                    return '请输入目标值';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的数字';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // 单位
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: "单位（可选）",
                hintText: "例如：杯、公里、页",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // 频率
          TextFont(
            text: "打卡频率",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Tappable(
                  onTap: () {
                    setState(() {
                      _selectedFrequency = HabitFrequency.daily;
                    });
                  },
                  color: _selectedFrequency == HabitFrequency.daily
                      ? getColor(context, "lightDarkAccent")
                      : Colors.transparent,
                  borderRadius: 12,
                  border: Border.all(
                    color: _selectedFrequency == HabitFrequency.daily
                        ? getColor(context, "accent")
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextFont(
                        text: "每日",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: _selectedFrequency == HabitFrequency.daily
                            ? getColor(context, "accent")
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Tappable(
                  onTap: () {
                    setState(() {
                      _selectedFrequency = HabitFrequency.weekly;
                    });
                  },
                  color: _selectedFrequency == HabitFrequency.weekly
                      ? getColor(context, "lightDarkAccent")
                      : Colors.transparent,
                  borderRadius: 12,
                  border: Border.all(
                    color: _selectedFrequency == HabitFrequency.weekly
                        ? getColor(context, "accent")
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextFont(
                        text: "每周",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: _selectedFrequency == HabitFrequency.weekly
                            ? getColor(context, "accent")
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Tappable(
                  onTap: () {
                    setState(() {
                      _selectedFrequency = HabitFrequency.monthly;
                    });
                  },
                  color: _selectedFrequency == HabitFrequency.monthly
                      ? getColor(context, "lightDarkAccent")
                      : Colors.transparent,
                  borderRadius: 12,
                  border: Border.all(
                    color: _selectedFrequency == HabitFrequency.monthly
                        ? getColor(context, "accent")
                        : getColor(context, "lightDarkAccent"),
                    width: 1.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextFont(
                        text: "每月",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: _selectedFrequency == HabitFrequency.monthly
                            ? getColor(context, "accent")
                            : getColor(context, "textLight"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // 颜色选择
          TextFont(
            text: "颜色",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          Tappable(
            onTap: () {
              openBottomSheet(
                context,
                ColorPicker(
                  selectedColor: _selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: getColor(context, "lightDarkAccent"),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: HexColor(_selectedColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFont(
                      text: _selectedColor,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: getColor(context, "textLight"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // 图标选择
          TextFont(
            text: "图标",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          Tappable(
            onTap: () {
              openBottomSheet(
                context,
                IconPicker(
                  selectedIcon: _selectedIcon,
                  onIconChanged: (icon) {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: getColor(context, "lightDarkAccent"),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    getIconData(_selectedIcon),
                    color: HexColor(_selectedColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFont(
                      text: _selectedIcon,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: getColor(context, "textLight"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return "每日打卡";
      case HabitFrequency.weekly:
        return "每周打卡";
      case HabitFrequency.monthly:
        return "每月打卡";
    }
  }

  double _getCompletionRate() {
    if (_habitWithRecords.records.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final startDate = _habitWithRecords.habit.createdDateTime;
    final totalDays = now.difference(startDate).inDays + 1;
    
    // 根据频率计算应该打卡的次数
    int expectedCount;
    switch (_habitWithRecords.habit.frequency) {
      case HabitFrequency.daily:
        expectedCount = totalDays;
        break;
      case HabitFrequency.weekly:
        expectedCount = (totalDays / 7).ceil();
        break;
      case HabitFrequency.monthly:
        expectedCount = (totalDays / 30).ceil();
        break;
    }
    
    if (expectedCount == 0) return 0.0;
    
    return _habitWithRecords.records.length / expectedCount;
  }

  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await HabitsDatabaseHelper.updateHabit(
        habitPk: _habitWithRecords.habit.habitPk,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        question: _questionController.text,
        colour: _selectedColor,
        iconName: _selectedIcon,
        emojiIconName: _selectedEmoji.isEmpty ? null : _selectedEmoji,
        frequency: _selectedFrequency,
        type: _selectedType,
        targetType: _selectedTargetType,
        targetValue: _selectedType == HabitType.numerical
            ? double.tryParse(_targetValueController.text) ?? 0.0
            : 0.0,
        unit: _unitController.text.isEmpty ? null : _unitController.text,
      );

      // 重新获取习惯数据
      final updatedHabit = await HabitsDatabaseHelper.getHabitWithRecords(_habitWithRecords.habit.habitPk);
      if (updatedHabit != null) {
        setState(() {
          _habitWithRecords = updatedHabit;
          _isEditing = false;
        });
      }
    } catch (e) {
      print('Error updating habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除习惯'),
        content: Text('确定要删除这个习惯吗？所有打卡记录也将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HabitsDatabaseHelper.deleteHabit(_habitWithRecords.habit.habitPk);
        Navigator.pop(context);
      } catch (e) {
        print('Error deleting habit: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord(HabitRecord record) async {
    try {
      await HabitsDatabaseHelper.deleteRecord(record.recordPk);
      
      // 重新获取习惯数据
      final updatedHabit = await HabitsDatabaseHelper.getHabitWithRecords(_habitWithRecords.habit.habitPk);
      if (updatedHabit != null) {
        setState(() {
          _habitWithRecords = updatedHabit;
        });
      }
    } catch (e) {
      print('Error deleting record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除记录失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
