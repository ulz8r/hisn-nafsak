import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../controllers/accountability_controller.dart';
import '../data/tasbeeh_data.dart';
import '../models/tasbeeh_model.dart';

class TasbeehScreen extends StatefulWidget {
  final SettingsController settingsController;
  final AccountabilityController? accountabilityController;

  const TasbeehScreen({
    super.key,
    required this.settingsController,
    this.accountabilityController,
  });

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with SingleTickerProviderStateMixin {
  late AccountabilityController _controller;
  TasbeehCategory _selectedCategory = TasbeehCategory.tasbeeh;
  int _selectedThikrIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.accountabilityController ?? AccountabilityController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<TasbeehThikr> get _currentCategoryThikrs {
    return TasbeehData.thikrList.where((t) => t.category == _selectedCategory).toList();
  }

  TasbeehThikr get _currentThikr {
    final list = _currentCategoryThikrs;
    if (_selectedThikrIndex >= list.length) {
      _selectedThikrIndex = 0;
    }
    return list[_selectedThikrIndex];
  }

  void _increment() {
    widget.settingsController.triggerTapFeedback();
    _pulseController.forward().then((_) => _pulseController.reverse());

    final thikr = _currentThikr;
    _controller.incrementTasbeeh(thikr.id);

    final currentCount = _controller.currentTasbeehLog?.getCount(thikr.id) ?? 0;
    final target = _controller.currentTasbeehLog?.getTarget(thikr.id, thikr.defaultTarget) ?? thikr.defaultTarget;

    if (currentCount + 1 == target) {
      widget.settingsController.triggerCompletionFeedback();
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تصفير العداد', style: AppTheme.getCairoFont(fontWeight: FontWeight.bold)),
          content: Text(
            'هل تريد بالتأكيد إعادة ضبط عداد "${_currentThikr.text}" لليوم؟',
            style: AppTheme.getCairoFont(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: AppTheme.getCairoFont(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.resetTasbeehCounter(_currentThikr.id);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: Text('تصفير', style: AppTheme.getCairoFont(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTarget = _controller.currentTasbeehLog?.getTarget(_currentThikr.id, _currentThikr.defaultTarget) ?? _currentThikr.defaultTarget;
    final customController = TextEditingController(text: currentTarget.toString());

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تحديد الهدف اليومي للذكر',
            style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: [33, 100, 500, 1000].map((t) {
                  return ActionChip(
                    label: Text('$t مرة', style: AppTheme.getCairoFont(fontSize: 12)),
                    onPressed: () {
                      _controller.setTasbeehTarget(_currentThikr.id, t);
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: customController,
                keyboardType: TextInputType.number,
                style: AppTheme.getCairoFont(),
                decoration: InputDecoration(
                  labelText: 'هدف مخصص',
                  labelStyle: AppTheme.getCairoFont(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: AppTheme.getCairoFont(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(customController.text);
                if (val != null && val > 0) {
                  _controller.setTasbeehTarget(_currentThikr.id, val);
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: Text('حفظ', style: AppTheme.getCairoFont(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'إحصائيات الأذكار لليوم',
                  style: AppTheme.getCairoFont(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...TasbeehCategory.values.map((cat) {
                  final count = _controller.getCategoryCount(cat);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TasbeehData.getCategoryName(cat),
                          style: AppTheme.getCairoFont(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$count مرة',
                          style: AppTheme.getCairoFont(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Text(
                  'إجمالي تسبيح اليوم: ${_controller.currentTasbeehLog?.totalAllToday ?? 0} مرة',
                  style: AppTheme.getCairoFont(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'المسبحة وعداد الأذكار',
            style: AppTheme.getArabicFont(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'إحصائيات الأذكار',
              onPressed: _showStatsSheet,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تصفير هذا الذكر',
              onPressed: _reset,
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final thikr = _currentThikr;
            final count = _controller.currentTasbeehLog?.getCount(thikr.id) ?? 0;
            final target = _controller.currentTasbeehLog?.getTarget(thikr.id, thikr.defaultTarget) ?? thikr.defaultTarget;
            final progress = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;

            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // تبويبات التصنيفات الرئيسية للأذكار
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: TasbeehCategory.values.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = TasbeehCategory.values[index];
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(
                            TasbeehData.getCategoryName(cat),
                            style: AppTheme.getCairoFont(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryGreen,
                          backgroundColor: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = cat;
                                _selectedThikrIndex = 0;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // قائمة الأذكار ضمن التصنيف المختار
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _currentCategoryThikrs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final t = _currentCategoryThikrs[index];
                        final isSelected = index == _selectedThikrIndex;
                        return FilterChip(
                          label: Text(
                            t.text,
                            style: AppTheme.getArabicFont(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black87 : (isDark ? Colors.white60 : Colors.grey.shade800),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.goldAccent,
                          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.08),
                          checkmarkColor: Colors.black87,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedThikrIndex = index;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // زر تغيير الهدف
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: _showTargetDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.goldAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flag_rounded, size: 14, color: AppTheme.goldAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'الهدف: $target مرة (اضغط للتعديل)',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // نص الذكر المعروض حالياً
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      thikr.text,
                      textAlign: TextAlign.center,
                      style: AppTheme.getArabicFont(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),

                  if (thikr.virtue != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        thikr.virtue!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.getArabicFont(
                          fontSize: 12.5,
                          color: isDark ? Colors.white60 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // الدائرة الكبيرة التفاعلية للتسبيح
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: _increment,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryGreen,
                              AppTheme.primaryGreenDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: count >= target ? Colors.greenAccent : AppTheme.goldAccent,
                            width: 3.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 6,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  count >= target ? Colors.greenAccent : AppTheme.goldAccent,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$count',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'من أصل $target',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.touch_app_outlined, color: AppTheme.goldAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'المس للتسبيح',
                                      style: AppTheme.getCairoFont(
                                        fontSize: 12,
                                        color: AppTheme.goldAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // شريط التحكم السفلي
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                          label: Text(
                            'تصفير العداد',
                            style: AppTheme.getCairoFont(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                        Text(
                          'إجمالي اليوم: ${_controller.currentTasbeehLog?.totalAllToday ?? 0}',
                          style: AppTheme.getCairoFont(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
