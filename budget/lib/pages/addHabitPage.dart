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

class AddHabitPage extends StatefulWidget {
  final VoidCallback? onHabitAdded;

  const AddHabitPage({
    Key? key,
    this.onHabitAdded,
  }) : super(key: key);

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();
  
  HabitType _selectedType = HabitType.yesNo;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  HabitTargetType _selectedTargetType = HabitTargetType.atLeast;
  String _selectedColor = "Blue";
  String _selectedIcon = "check_circle";
  String _selectedEmoji = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 设置默认问题
    _questionController.text = "今天完成了吗？";
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
    return PageFramework(
      title: "添加习惯",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveHabit,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.save),
        label: TextFont(
          text: "保存",
          textColor: Colors.white,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SizedBox(height: 8),
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
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await HabitsDatabaseHelper.createHabit(
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

      if (widget.onHabitAdded != null) {
        widget.onHabitAdded!();
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error saving habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
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
