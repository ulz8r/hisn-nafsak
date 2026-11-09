import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/thikr_model.dart';
import '../data/sleep_wake_athkar_data.dart';
import '../controllers/settings_controller.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'athkar_reader_screen.dart';

/// شاشة أذكار النوم والاستيقاظ من النوم
class SleepWakeScreen extends StatefulWidget {
  final SettingsController settingsController;
  final int initialTabIndex; // 0: النوم, 1: الاستيقاظ

  const SleepWakeScreen({
    super.key,
    required this.settingsController,
    this.initialTabIndex = 0,
  });

  @override
  State<SleepWakeScreen> createState() => _SleepWakeScreenState();
}

class _SleepWakeScreenState extends State<SleepWakeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _fontSizeDelta = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ الذكر المبارك بنجاح',
              style: AppTheme.getCairoFont(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openReader(BuildContext context, {required bool isSleep}) async {
    final sectionKey = isSleep ? 'sleep_athkar' : 'wake_athkar';
    final list = isSleep ? SleepWakeAthkarData.sleepAthkar : SleepWakeAthkarData.wakeAthkar;
    final title = isSleep ? 'أذكار النوم الصحيحة' : 'أذكار الاستيقاظ من النوم';

    final lastIdx = await StorageService.instance.getLibraryLastPosition(sectionKey);
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AthkarReaderScreen(
          title: title,
          athkarList: list,
          isMorning: !isSleep,
          settingsController: widget.settingsController,
          initialIndex: (lastIdx - 1).clamp(0, list.length - 1),
          sectionKey: sectionKey,
          customPrimaryColor: isSleep ? const Color(0xFF312E81) : const Color(0xFFD97706),
          customGradientColors: isSleep
              ? const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)]
              : const [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: Text(
            'أذكار النوم والاستيقاظ',
            style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            // أزرار تكبير وتصغير الخط
            IconButton(
              icon: const Icon(Icons.text_increase_rounded, size: 20),
              tooltip: 'تكبير الخط',
              onPressed: () {
                if (_fontSizeDelta < 8.0) {
                  setState(() => _fontSizeDelta += 2.0);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.text_decrease_rounded, size: 20),
              tooltip: 'تصغير الخط',
              onPressed: () {
                if (_fontSizeDelta > -4.0) {
                  setState(() => _fontSizeDelta -= 2.0);
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.goldAccent,
            indicatorWeight: 3.5,
            labelColor: AppTheme.goldAccent,
            unselectedLabelColor: Colors.white70,
            labelStyle: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: AppTheme.getCairoFont(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: const [
              Tab(
                icon: Icon(Icons.bedtime_rounded, size: 20),
                text: 'أذكار النوم (٩)',
              ),
              Tab(
                icon: Icon(Icons.wb_twilight_rounded, size: 20),
                text: 'أذكار الاستيقاظ (٣)',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // تبويب أذكار النوم
            _buildAthkarTab(
              context: context,
              athkar: SleepWakeAthkarData.sleepAthkar,
              isSleep: true,
              isDark: isDark,
              headerTitle: 'من أذكار النوم الصحيحة',
              headerSubtitle: 'سكينة وطمأنينة وحفظ للنفس حتى تصبح',
              gradientColors: const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            ),
            // تبويب أذكار الاستيقاظ
            _buildAthkarTab(
              context: context,
              athkar: SleepWakeAthkarData.wakeAthkar,
              isSleep: false,
              isDark: isDark,
              headerTitle: 'أذكار الاستيقاظ من النوم',
              headerSubtitle: 'شكر لله على نعمة الحياة وانشراح الصدر لليوم الجديد',
              gradientColors: const [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthkarTab({
    required BuildContext context,
    required List<Thikr> athkar,
    required bool isSleep,
    required bool isDark,
    required String headerTitle,
    required String headerSubtitle,
    required List<Color> gradientColors,
  }) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: athkar.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // بطاقة البداية وبدء القراءة بالعداد التفاعلي
          return _buildHeaderHero(
            context: context,
            title: headerTitle,
            subtitle: headerSubtitle,
            count: athkar.length,
            isSleep: isSleep,
            gradientColors: gradientColors,
          );
        }

        final thikr = athkar[index - 1];
        return _buildThikrCard(
          context: context,
          thikr: thikr,
          index: index,
          total: athkar.length,
          isDark: isDark,
          accentColor: gradientColors[1],
        );
      },
    );
  }

  Widget _buildHeaderHero({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int count,
    required bool isSleep,
    required List<Color> gradientColors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSleep ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.getCairoFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.getCairoFont(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '$count أذكار',
                  style: AppTheme.getCairoFont(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // زر بدء القراءة التفاعلية بالعداد
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openReader(context, isSleep: isSleep),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              label: Text(
                'ابدأ القراءة بالعداد التفاعلي',
                style: AppTheme.getCairoFont(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccentDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThikrCard({
    required BuildContext context,
    required Thikr thikr,
    required int index,
    required int total,
    required bool isDark,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : accentColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الترويسة العلوية للبطاقة: رقم الذكر والتكرار وزر النسخ
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: AppTheme.getCairoFont(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // شارة عدد المرات
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.goldAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    thikr.countDescription,
                    style: AppTheme.getCairoFont(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.goldAccent : const Color(0xFFB45309),
                    ),
                  ),
                ),
                const Spacer(),
                // زر النسخ
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'نسخ نص الذكر',
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  onPressed: () => _copyToClipboard(context, thikr.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // نص الذكر الشريف
            SelectableText(
              thikr.text,
              style: AppTheme.getArabicFont(
                fontSize: 19 + _fontSizeDelta,
                height: 1.85,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // المصدر والتخريج والفضل
            if (thikr.source != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bookmark_added_rounded, size: 15, color: AppTheme.goldAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      thikr.source!,
                      style: AppTheme.getCairoFont(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.goldAccent : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            // فضل الذكر
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 15,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    thikr.reward,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if (thikr.note != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'توجيه: ${thikr.note!}',
                  style: AppTheme.getCairoFont(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
