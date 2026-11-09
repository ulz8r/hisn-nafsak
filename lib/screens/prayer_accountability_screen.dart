import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/accountability_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/sunan_data.dart';
import '../models/prayer_model.dart';
import 'package:intl/intl.dart' hide TextDirection;

class PrayerAccountabilityScreen extends StatelessWidget {
  final AccountabilityController controller;
  final SettingsController settingsController;

  const PrayerAccountabilityScreen({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  String _formatArabicDate(DateTime date) {
    return DateFormat('EEEE، d MMMM y', 'ar').format(date);
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await controller.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'محاسبة الصلوات والسنن',
            style: AppTheme.getArabicFont(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'اختيار التاريخ',
              onPressed: () => _pickDate(context),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.isLoading || controller.currentPrayerLog == null) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
            }

            final prayerLog = controller.currentPrayerLog!;
            final prayedCount = prayerLog.totalPrayedCount;
            final jamaahCount = prayerLog.jamaahCount;
            final percentage = (prayerLog.prayerPercentage * 100).round();

            // حساب ركعات السنن
            var completedMuakkadahRakahs = 0;
            var completedMustahabbahRakahs = 0;
            var totalCompletedSunanRakahs = 0;

            for (final sunnah in SunanData.allSunan) {
              final isDone = prayerLog.sunanStatus[sunnah.id] ?? false;
              if (isDone) {
                totalCompletedSunanRakahs += sunnah.rakahs;
                if (sunnah.type == SunnahType.muakkadah) {
                  completedMuakkadahRakahs += sunnah.rakahs;
                } else {
                  completedMustahabbahRakahs += sunnah.rakahs;
                }
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط التنقل بين الأيام
                  _buildDateNavigator(context, isDark),

                  const SizedBox(height: 14),

                  // بطاقة الإحصائية السريعة للصلوات الخمس
                  _buildPrayerStatsSummary(
                    isDark: isDark,
                    prayedCount: prayedCount,
                    jamaahCount: jamaahCount,
                    percentage: percentage,
                  ),

                  const SizedBox(height: 20),

                  // عنوان قسم الصلوات الخمس
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mosque_rounded, color: AppTheme.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'الصلوات الخمس المفروضة',
                        style: AppTheme.getCairoFont(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // جدول / بطاقات الصلوات الخمس
                  _buildPrayersTable(context, isDark, prayerLog),

                  const SizedBox(height: 26),

                  // عنوان قسم السنن الرواتب والمستحبة
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السنن الرواتب والمستحبة',
                              style: AppTheme.getCairoFont(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                              ),
                            ),
                            Text(
                              'المؤكدة: $completedMuakkadahRakahs من ${SunanData.totalMuakkadahRakahs} ركعة  |  المستحبة: $completedMustahabbahRakahs  |  الإجمالي: $totalCompletedSunanRakahs ركعة',
                              style: AppTheme.getCairoFont(
                                fontSize: 12,
                                color: isDark ? AppTheme.goldAccent : Colors.brown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // فضل السنن الرواتب المؤكدة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      SunanData.muakkadahHadith,
                      style: AppTheme.getArabicFont(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF92400E),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // قائمة السنن الرواتب مرتبة حسب الصلوات
                  _buildSunanList(context, isDark, prayerLog),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            tooltip: 'اليوم السابق',
            onPressed: () => controller.goToPreviousDay(),
          ),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatArabicDate(controller.selectedDate),
                        style: AppTheme.getCairoFont(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.goldAccent),
                    ],
                  ),
                  if (controller.isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'اليوم',
                        style: AppTheme.getCairoFont(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            tooltip: 'اليوم التالي',
            onPressed: controller.isToday ? null : () => controller.goToNextDay(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerStatsSummary({
    required bool isDark,
    required int prayedCount,
    required int jamaahCount,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF142C21), const Color(0xFF0F1E17)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill(
            title: 'المفروضة',
            value: '$prayedCount / 5',
            color: AppTheme.primaryGreen,
            icon: Icons.check_circle_outline,
            isDark: isDark,
          ),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
          _buildStatPill(
            title: 'صلاة جماعة',
            value: '$jamaahCount صلوات',
            color: Colors.blue.shade700,
            icon: Icons.groups_rounded,
            isDark: isDark,
          ),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
          _buildStatPill(
            title: 'نسبة الإنجاز',
            value: '$percentage%',
            color: percentage == 100 ? Colors.green.shade700 : AppTheme.goldAccent,
            icon: Icons.pie_chart_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTheme.getCairoFont(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.getCairoFont(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : color,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayersTable(BuildContext context, bool isDark, DayPrayerLog prayerLog) {
    final prayersList = [
      {'id': 'fajr', 'name': 'صلاة الفجر', 'icon': Icons.wb_twilight_rounded},
      {'id': 'dhuhr', 'name': 'صلاة الظهر', 'icon': Icons.wb_sunny_rounded},
      {'id': 'asr', 'name': 'صلاة العصر', 'icon': Icons.wb_sunny_outlined},
      {'id': 'maghrib', 'name': 'صلاة المغرب', 'icon': Icons.nightlight_outlined},
      {'id': 'isha', 'name': 'صلاة العشاء', 'icon': Icons.nightlight_round},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'الصلاة',
                    style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'هل أديت الصلاة؟',
                      style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'هل أديتها جماعة؟',
                      style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // صفوف الصلوات الخمس
          ...prayersList.map((p) {
            final id = p['id'] as String;
            final name = p['name'] as String;
            final icon = p['icon'] as IconData;
            final prayerItem = prayerLog.prayers[id] ?? PrayerItem(id: id, name: name);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      // اسم الصلاة وأيقونتها
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(icon, size: 20, color: AppTheme.goldAccent),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: AppTheme.getCairoFont(
                                fontSize: 14,
                                fontWeight: prayerItem.prayed ? FontWeight.bold : FontWeight.normal,
                                color: prayerItem.prayed
                                    ? (isDark ? Colors.white : AppTheme.primaryGreenDark)
                                    : (isDark ? Colors.white60 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // مربعات الاختيار: هل أديت الصلاة؟ (مربع لـ نعم ومربع لـ لا)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              _buildChoiceBox(
                                label: 'نعم',
                                icon: Icons.check_rounded,
                                isSelected: prayerItem.prayed,
                                activeColor: Colors.green.shade600,
                                isDark: isDark,
                                onTap: () {
                                  settingsController.triggerTapFeedback();
                                  controller.togglePrayerStatus(id, prayed: true);
                                },
                              ),
                              const SizedBox(width: 6),
                              _buildChoiceBox(
                                label: 'لا',
                                icon: Icons.close_rounded,
                                isSelected: !prayerItem.prayed,
                                activeColor: Colors.red.shade600,
                                isDark: isDark,
                                onTap: () {
                                  settingsController.triggerTapFeedback();
                                  controller.togglePrayerStatus(id, prayed: false);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // مربعات الاختيار: هل أديتها في جماعة؟ (مربع لـ نعم ومربع لـ لا)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              _buildChoiceBox(
                                label: 'نعم',
                                icon: Icons.groups_rounded,
                                isEnabled: prayerItem.prayed,
                                isSelected: prayerItem.prayed && prayerItem.inJamaah,
                                activeColor: Colors.blue.shade700,
                                isDark: isDark,
                                onTap: prayerItem.prayed
                                    ? () {
                                        settingsController.triggerTapFeedback();
                                        controller.togglePrayerStatus(id, inJamaah: true);
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'يجب تحديد أداء الصلاة أولاً (نعم) لتحديد صلاتها جماعة.',
                                              style: AppTheme.getCairoFont(),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                              ),
                              const SizedBox(width: 6),
                              _buildChoiceBox(
                                label: 'لا',
                                icon: Icons.person_outline_rounded,
                                isEnabled: prayerItem.prayed,
                                isSelected: prayerItem.prayed && !prayerItem.inJamaah,
                                activeColor: Colors.orange.shade800,
                                isDark: isDark,
                                onTap: prayerItem.prayed
                                    ? () {
                                        settingsController.triggerTapFeedback();
                                        controller.togglePrayerStatus(id, inJamaah: false);
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'يجب تحديد أداء الصلاة أولاً (نعم) لتحديد صلاتها جماعة.',
                                              style: AppTheme.getCairoFont(),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (id != 'isha') const Divider(height: 1, indent: 14, endIndent: 14),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChoiceBox({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
    bool isEnabled = true,
    IconData? icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !isEnabled
                ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.withValues(alpha: 0.08))
                : (isSelected
                    ? activeColor
                    : (isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.12))),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.25)),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && isSelected) ...[
                Icon(icon, size: 13, color: Colors.white),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: AppTheme.getCairoFont(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: !isEnabled
                      ? (isDark ? Colors.white24 : Colors.grey.shade400)
                      : (isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSunanList(BuildContext context, bool isDark, DayPrayerLog prayerLog) {
    return Column(
      children: SunanData.allSunan.map((sunnah) {
        final isDone = prayerLog.sunanStatus[sunnah.id] ?? false;
        final isMuakkadah = sunnah.type == SunnahType.muakkadah;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone
                  ? Colors.green.withValues(alpha: 0.6)
                  : (isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2)),
              width: isDone ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              settingsController.triggerTapFeedback();
              controller.toggleSunnahStatus(sunnah.id);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // شيك بوكس دائري
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.green.shade600 : Colors.transparent,
                      border: Border.all(
                        color: isDone ? Colors.green.shade600 : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),

                  // تفاصيل السنة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              sunnah.title,
                              style: AppTheme.getCairoFont(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMuakkadah
                                    ? AppTheme.goldAccent.withValues(alpha: 0.15)
                                    : Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isMuakkadah
                                      ? AppTheme.goldAccent
                                      : Colors.blue.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                isMuakkadah ? 'راتبة مؤكدة' : 'سنة مستحبة',
                                style: AppTheme.getCairoFont(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMuakkadah ? AppTheme.goldAccent : Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sunnah.reward,
                          style: AppTheme.getArabicFont(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
