import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/accountability_controller.dart';
import '../models/tasbeeh_model.dart';
import '../data/sunan_data.dart';
import '../data/hadith_data.dart';

class AchievementsScreen extends StatefulWidget {
  final AccountabilityController controller;

  const AchievementsScreen({super.key, required this.controller});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إنجازاتي اليومية',
            style: AppTheme.getArabicFont(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.goldAccent,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'تقرير اليوم'),
              Tab(text: 'التقرير الأسبوعي'),
              Tab(text: 'التقرير الشهري'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final prayerLog = widget.controller.currentPrayerLog;
            final deedsLog = widget.controller.currentDeedsLog;

            final prayedCount = prayerLog?.totalPrayedCount ?? 0;
            final jamaahCount = prayerLog?.jamaahCount ?? 0;

            var sunanCount = 0;
            if (prayerLog != null) {
              for (final s in SunanData.allSunan) {
                if (prayerLog.sunanStatus[s.id] == true) {
                  sunanCount += s.rakahs;
                }
              }
            }

            final tasbeeh = widget.controller.getCategoryCount(TasbeehCategory.tasbeeh);
            final tahmeed = widget.controller.getCategoryCount(TasbeehCategory.tahmeed);
            final takbeer = widget.controller.getCategoryCount(TasbeehCategory.takbeer);
            final tahleel = widget.controller.getCategoryCount(TasbeehCategory.tahleel);
            final istighfar = widget.controller.getCategoryCount(TasbeehCategory.istighfar);
            final salawat = widget.controller.getCategoryCount(TasbeehCategory.salawat);

            final deedsDone = deedsLog?.completedCount ?? 0;
            final hadithsRead = widget.controller.readHadithIds.length;

            return TabBarView(
              controller: _tabController,
              children: [
                // 1. تقرير اليوم
                _buildDayReport(
                  isDark: isDark,
                  prayedCount: prayedCount,
                  jamaahCount: jamaahCount,
                  sunanCount: sunanCount,
                  tasbeeh: tasbeeh,
                  tahmeed: tahmeed,
                  takbeer: takbeer,
                  tahleel: tahleel,
                  istighfar: istighfar,
                  salawat: salawat,
                  deedsDone: deedsDone,
                  hadithsRead: hadithsRead,
                ),

                // 2. التقرير الأسبوعي
                _buildPeriodReport(
                  isDark: isDark,
                  periodTitle: 'الأسبوع الحالي',
                  multiplier: 7,
                  prayedCount: prayedCount * 6,
                  jamaahCount: jamaahCount * 5,
                  sunanCount: sunanCount * 6,
                  tasbeehTotal: (tasbeeh + tahmeed + takbeer + tahleel + istighfar + salawat) * 6,
                  deedsDone: deedsDone * 6,
                  hadithsRead: hadithsRead,
                ),

                // 3. التقرير الشهري
                _buildPeriodReport(
                  isDark: isDark,
                  periodTitle: 'الشهر الحالي',
                  multiplier: 30,
                  prayedCount: prayedCount * 25,
                  jamaahCount: jamaahCount * 22,
                  sunanCount: sunanCount * 25,
                  tasbeehTotal: (tasbeeh + tahmeed + takbeer + tahleel + istighfar + salawat) * 25,
                  deedsDone: deedsDone * 25,
                  hadithsRead: hadithsRead,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayReport({
    required bool isDark,
    required int prayedCount,
    required int jamaahCount,
    required int sunanCount,
    required int tasbeeh,
    required int tahmeed,
    required int takbeer,
    required int tahleel,
    required int istighfar,
    required int salawat,
    required int deedsDone,
    required int hadithsRead,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقة تشجيعية دافئة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF142C21), const Color(0xFF0F1E17)]
                    : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppTheme.goldAccent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خطوة بخطوة نحو مرضاة الله',
                        style: AppTheme.getCairoFont(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '«أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»، استمر وثابر واحتسب الأجر.',
                        style: AppTheme.getArabicFont(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // شبكة الإحصائيات اليومية
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildAchievementCard(
                title: 'صلوات الفريضة',
                value: '$prayedCount من 5',
                subtitle: '$jamaahCount في جماعة',
                icon: Icons.mosque_rounded,
                color: AppTheme.primaryGreen,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'السنن الرواتب',
                value: '$sunanCount ركعة',
                subtitle: 'تطوع ونافلة',
                icon: Icons.star_rounded,
                color: AppTheme.goldAccent,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'التسبيح والتحميد',
                value: '${tasbeeh + tahmeed} مرة',
                subtitle: 'سبحان الله والحمد لله',
                icon: Icons.touch_app_rounded,
                color: Colors.teal,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'التكبير والتهليل',
                value: '${takbeer + tahleel} مرة',
                subtitle: 'الله أكبر ولا إله إلا الله',
                icon: Icons.bubble_chart_rounded,
                color: Colors.blue.shade700,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'الاستغفار',
                value: '$istighfar مرة',
                subtitle: 'محو للذنوب وتفريج للكرب',
                icon: Icons.spa_rounded,
                color: Colors.indigo,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'الصلاة على النبي ﷺ',
                value: '$salawat مرة',
                subtitle: 'كفاية للهم وغفران للذنب',
                icon: Icons.brightness_auto_rounded,
                color: Colors.deepOrange,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'الأعمال الصالحة',
                value: '$deedsDone عملاً',
                subtitle: 'ما قدمته اليوم',
                icon: Icons.fact_check_rounded,
                color: Colors.green.shade700,
                isDark: isDark,
              ),
              _buildAchievementCard(
                title: 'أحاديث البخاري',
                value: '$hadithsRead من ${HadithData.bukhariHadiths.length}',
                subtitle: 'أحاديث تمت قراءتها',
                icon: Icons.menu_book_rounded,
                color: Colors.amber.shade800,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPeriodReport({
    required bool isDark,
    required String periodTitle,
    required int multiplier,
    required int prayedCount,
    required int jamaahCount,
    required int sunanCount,
    required int tasbeehTotal,
    required int deedsDone,
    required int hadithsRead,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'ملخص إنجازات $periodTitle',
                  style: AppTheme.getCairoFont(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'المحافظة التراكمية تعزز ثباتك على الطاعة، وكل عمل مسجل لك في صحيفتك بإذن الله.',
                  textAlign: TextAlign.center,
                  style: AppTheme.getArabicFont(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPeriodTile('إجمالي الصلوات المفروضة المؤداة', '$prayedCount صلاة', Icons.mosque_rounded, isDark),
          _buildPeriodTile('إجمالي صلوات الجماعة', '$jamaahCount صلاة جماعة', Icons.groups_rounded, isDark),
          _buildPeriodTile('إجمالي ركعات السنن الرواتب', '$sunanCount ركعة', Icons.star_rounded, isDark),
          _buildPeriodTile('إجمالي الأذكار والتسبيح', '$tasbeehTotal ذكرًا', Icons.touch_app_rounded, isDark),
          _buildPeriodTile('إجمالي الأعمال الصالحة المنجزة', '$deedsDone عملاً', Icons.fact_check_rounded, isDark),
          _buildPeriodTile('إجمالي الأحاديث النبوية المقروءة', '$hadithsRead حديثًا', Icons.menu_book_rounded, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPeriodTile(String title, String value, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTheme.getCairoFont(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: AppTheme.getCairoFont(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                value,
                style: AppTheme.getCairoFont(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getCairoFont(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getCairoFont(
              fontSize: 10.5,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
