import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/accountability_controller.dart';
import '../controllers/settings_controller.dart';
import 'package:intl/intl.dart' hide TextDirection;

class DailyDeedsScreen extends StatefulWidget {
  final AccountabilityController controller;
  final SettingsController settingsController;

  const DailyDeedsScreen({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  @override
  State<DailyDeedsScreen> createState() => _DailyDeedsScreenState();
}

class _DailyDeedsScreenState extends State<DailyDeedsScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.controller.currentDeedsLog?.notes ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant DailyDeedsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.currentDeedsLog?.notes != _notesController.text) {
      _notesController.text = widget.controller.currentDeedsLog?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatArabicDate(DateTime date) {
    return DateFormat('EEEE، d MMMM y', 'ar').format(date);
  }

  void _showAddCustomDeedDialog() {
    final customController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.add_task_rounded, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'إضافة عمل صالح جديد',
                  style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: TextField(
              controller: customController,
              autofocus: true,
              style: AppTheme.getCairoFont(),
              decoration: InputDecoration(
                hintText: 'مثال: صيام يوم الخميس، قراءة صفحة تفسير...',
                hintStyle: AppTheme.getCairoFont(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('إلغاء', style: AppTheme.getCairoFont(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (customController.text.trim().isNotEmpty) {
                    widget.controller.addCustomDeed(customController.text.trim());
                    Navigator.of(ctx).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'إضافة',
                  style: AppTheme.getCairoFont(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSummarySheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final log = widget.controller.currentDeedsLog;
    if (log == null) return;

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
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'ملخص إنجازاتي اليوم',
                    textAlign: TextAlign.center,
                    style: AppTheme.getCairoFont(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // بطاقة الإحصائيات
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                              const SizedBox(height: 4),
                              Text('أنجزته اليوم', style: AppTheme.getCairoFont(fontSize: 12)),
                              Text(
                                '${log.completedCount}',
                                style: AppTheme.getCairoFont(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.alarm_on_rounded, color: Colors.orange, size: 24),
                              const SizedBox(height: 4),
                              Text('فاتني وأريد تحسينه', style: AppTheme.getCairoFont(fontSize: 12)),
                              Text(
                                '${log.missedDeeds.length}',
                                style: AppTheme.getCairoFont(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // قائمة الأعمال المنجزة
                  if (log.completedDeeds.isNotEmpty) ...[
                    Text(
                      'ما أنجزته بحمد الله:',
                      style: AppTheme.getCairoFont(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...log.completedDeeds.map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.title,
                                  style: AppTheme.getCairoFont(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // قائمة ما فات للتحسين غداً
                  if (log.missedDeeds.isNotEmpty) ...[
                    Text(
                      'أعمال أجتهد في إنجازها غداً بإذن الله:',
                      style: AppTheme.getCairoFont(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...log.missedDeeds.map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_right, color: Colors.orange, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  d.title,
                                  style: AppTheme.getCairoFont(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              );
            },
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
            'ماذا قدمت اليوم؟',
            style: AppTheme.getArabicFont(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: 'ملخص اليوم',
              onPressed: _showSummarySheet,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddCustomDeedDialog,
          backgroundColor: AppTheme.primaryGreen,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'إضافة عمل مخصص',
            style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            if (widget.controller.isLoading || widget.controller.currentDeedsLog == null) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
            }

            final deedsLog = widget.controller.currentDeedsLog!;
            final completedCount = deedsLog.completedCount;
            final totalCount = deedsLog.totalCount;
            final progressPercent = (deedsLog.completionRate * 100).round();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط التاريخ
                  _buildDateNavigator(isDark),

                  const SizedBox(height: 14),

                  // بطاقة نسبة إنجاز الأعمال
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fact_check_rounded, color: AppTheme.primaryGreen, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'إنجاز الأعمال الصالحة اليوم:',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$completedCount من $totalCount عمل',
                              style: AppTheme.getCairoFont(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: deedsLog.completionRate,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressPercent >= 80 ? Colors.green : AppTheme.goldAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'قائمة الأعمال لمحاسبة النفس:',
                    style: AppTheme.getCairoFont(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // قائمة الأعمال
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deedsLog.deeds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final deed = deedsLog.deeds[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: deed.isCompleted
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.15),
                            width: deed.isCompleted ? 1.5 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: deed.isCompleted,
                          activeColor: Colors.green.shade600,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          title: Text(
                            deed.title,
                            style: AppTheme.getCairoFont(
                              fontSize: 13.5,
                              fontWeight: deed.isCompleted ? FontWeight.bold : FontWeight.normal,
                              color: deed.isCompleted
                                  ? (isDark ? Colors.white : AppTheme.primaryGreenDark)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          secondary: deed.isCustom
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'مخصص',
                                    style: AppTheme.getCairoFont(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.goldAccent,
                                    ),
                                  ),
                                )
                              : null,
                          onChanged: (_) {
                            widget.settingsController.triggerTapFeedback();
                            widget.controller.toggleDeedStatus(deed.id);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // خانة الملاحظات اليومية
                  Text(
                    'ملاحظات وخواطر اليوم:',
                    style: AppTheme.getCairoFont(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      style: AppTheme.getCairoFont(fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'اكتب هنا ما تود تذكره، تقصير شعرت به، أو نية طاعة تنويها...',
                        hintStyle: AppTheme.getCairoFont(fontSize: 13, color: Colors.grey),
                      ),
                      onChanged: (val) => widget.controller.updateDeedsNotes(val),
                    ),
                  ),

                  const SizedBox(height: 80), // مساحة للـ Floating Action Button
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateNavigator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            tooltip: 'اليوم السابق',
            onPressed: () => widget.controller.goToPreviousDay(),
          ),
          Text(
            _formatArabicDate(widget.controller.selectedDate),
            style: AppTheme.getCairoFont(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.primaryGreenDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            tooltip: 'اليوم التالي',
            onPressed: widget.controller.isToday ? null : () => widget.controller.goToNextDay(),
          ),
        ],
      ),
    );
  }
}
