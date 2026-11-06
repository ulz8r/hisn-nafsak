import 'package:flutter/material.dart';
import '../data/athkar_data.dart';
import '../data/post_prayer_athkar_data.dart';
import '../theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../controllers/accountability_controller.dart';
import '../services/storage_service.dart';
import 'athkar_reader_screen.dart';
import 'document_reader_screen.dart';
import 'tasbeeh_screen.dart';
import 'prayer_accountability_screen.dart';
import 'daily_deeds_screen.dart';
import 'hadith_screen.dart';
import 'achievements_screen.dart';
import 'waqfa_screen.dart';

class HomeScreen extends StatelessWidget {
  final SettingsController settingsController;
  final AccountabilityController accountabilityController;

  const HomeScreen({
    super.key,
    required this.settingsController,
    required this.accountabilityController,
  });

  bool _isMorningTime() {
    final hour = DateTime.now().hour;
    // من الفجر إلى الظهر/العصر صباح
    return hour >= 4 && hour < 14;
  }

  void _showSettingsDialog(BuildContext context) {
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
          child: AnimatedBuilder(
            animation: settingsController,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'إعدادات التطبيق',
                      style: AppTheme.getCairoFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        'الوضع الليلي',
                        style: AppTheme.getCairoFont(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'تبديل مظهر التطبيق إلى الداكن',
                        style: AppTheme.getCairoFont(fontSize: 12, color: Colors.grey),
                      ),
                      value: settingsController.isDarkMode,
                      activeThumbColor: AppTheme.goldAccent,
                      onChanged: (val) => settingsController.toggleDarkMode(val),
                    ),
                    SwitchListTile(
                      title: Text(
                        'الاهتزاز عند الضغط',
                        style: AppTheme.getCairoFont(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'تفعيل تفاعل الاهتزاز مع عداد الذكر',
                        style: AppTheme.getCairoFont(fontSize: 12, color: Colors.grey),
                      ),
                      value: settingsController.vibrationEnabled,
                      activeThumbColor: AppTheme.goldAccent,
                      onChanged: (val) => settingsController.toggleVibration(val),
                    ),
                    SwitchListTile(
                      title: Text(
                        'الانتقال التلقائي للذكر التالي',
                        style: AppTheme.getCairoFont(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'الانتقال التلقائي بمجرد اكتمال عدد تكرار الذكر الحالي',
                        style: AppTheme.getCairoFont(fontSize: 12, color: Colors.grey),
                      ),
                      value: settingsController.autoAdvanceEnabled,
                      activeThumbColor: AppTheme.goldAccent,
                      onChanged: (val) => settingsController.toggleAutoAdvance(val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'حجم خط الأذكار:',
                          style: AppTheme.getCairoFont(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Slider(
                            value: settingsController.fontSize,
                            min: 16.0,
                            max: 34.0,
                            divisions: 9,
                            activeColor: AppTheme.goldAccent,
                            label: settingsController.fontSize.round().toString(),
                            onChanged: (val) => settingsController.setFontSize(val),
                          ),
                        ),
                        Text(
                          '${settingsController.fontSize.round()}',
                          style: AppTheme.getCairoFont(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDuaaDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppTheme.goldAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  'دعاء مبارك',
                  style: AppTheme.getCairoFont(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : AppTheme.lightBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'اللَّهُمَّ اغْفِرْ وَارْحَمْ وَعَافِ وَاعْفُ عَمَّنْ أَنْشَأَ هَذَا التَّطْبِيقَ وَوَالِدَيْهِ، '
                      'وَارْحَمْ وَاغْفِرْ لِكُلِّ مَنْ قَرَأَ هَذِهِ الْأَذْكَارَ وَعَمِلَ بِهَا وَنَشَرَهَا، '
                      'اللَّهُمَّ اجْعَلْهُ عِلْمًا نَافِعًا وَعَمَلًا صَالِحًا وَصَدَقَةً جَارِيَةً، '
                      'وَاحْفَظْنَا وَإِيَّاهُمْ بِحِفْظِكَ التَّامِّ، وَأَدْخِلْنَا جَمِيعًا الفِرْدَوْسَ الْأَعْلَى مِنَ الْجَنَّةِ بِغَيْرِ حِسَابٍ وَلَا سَابِقَةِ عَذَابٍ. آمين.',
                      textAlign: TextAlign.center,
                      style: AppTheme.getArabicFont(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.8,
                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'قال رسول الله ﷺ:\n"دَعْوَةُ الْمَرْءِ الْمُسْلِمِ لِأَخِيهِ بِظَهْرِ الْغَيْبِ مُسْتَجَابَةٌ، عِنْدَ رَأْسِهِ مَلَكٌ مُوَكَّلٌ كُلَّمَا دَعَا لِأَخِيهِ بِخَيْرٍ، قَالَ الْمَلَكُ الْمُوَكَّلُ بِهِ: آمِينَ وَلَكَ بِمِثْلٍ".\n[رواه مسلم]',
                    textAlign: TextAlign.center,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('تقبل الله', style: AppTheme.getCairoFont(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVirtuesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  'فضل أذكار الصباح والمساء',
                  style: AppTheme.getCairoFont(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? Colors.white : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• حِصْنٌ منيع وحِرز حريز من الشياطين وشرور الإنس والجن والهم والغم.\n\n'
                    '• جلب للطمأنينة وانشراح الصدر والسكينة في القلب والبيت.\n\n'
                    '• امتثال لأمر الله تعالى: ﴿ وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا ﴾.\n\n'
                    '• تكفير للسيئات ورفع للدرجات ومضاعفة للأجور والحسنات.\n\n'
                    '• حفظ للبدن والسمع والبصر والأهل والمال والنفس طوال اليوم والليلة.',
                    style: AppTheme.getArabicFont(
                      fontSize: 16,
                      height: 1.7,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إغلاق', style: AppTheme.getCairoFont(color: AppTheme.goldAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMorning = _isMorningTime();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ترويسة التطبيق الجذابة مع اسم التطبيق
            SliverAppBar(
              expandedHeight: 220.0,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  tooltip: 'الإعدادات',
                  onPressed: () => _showSettingsDialog(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'حِصْنُ نَفْسِكَ',
                  style: AppTheme.getArabicFont(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // تدرج لوني إسلامي فخم
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF063A24),
                            Color(0xFF0F5C3A),
                            Color(0xFF1B8A5A),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                    // زخارف إسلامية ونصوص تقديمية
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                  size: 16,
                                  color: AppTheme.goldAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isMorning ? 'صباح مفعم بالذكر والبركات' : 'مساء عامر بالطمأنينة والسكينة',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'أذكار الصباح والمساء والقرآن الكريم ومحاسبة النفس',
                            textAlign: TextAlign.center,
                            style: AppTheme.getArabicFont(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // المحتوى الرئيسي
            SliverPadding(
              padding: const EdgeInsets.all(18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // ================= قسم أذكار اليوم والليلة =================
                  // بطاقة أذكار الصباح الكبيرة
                  _buildAthkarHeroCard(
                    context: context,
                    title: 'أذكار الصباح',
                    subtitle: 'حفظ وبركة ليومك من صلاة الصبح حتى المساء',
                    countText: '${AthkarData.morningAthkar.length} ذكرًا مباركًا',
                    icon: Icons.wb_sunny_rounded,
                    gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFB45309)],
                    isHighlight: isMorning,
                    onTap: () async {
                      final lastIdx = await StorageService.instance.getLibraryLastPosition('morning');
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AthkarReaderScreen(
                              title: 'أذكار الصباح',
                              athkarList: AthkarData.morningAthkar,
                              isMorning: true,
                              settingsController: settingsController,
                              initialIndex: (lastIdx - 1).clamp(0, AthkarData.morningAthkar.length - 1),
                              sectionKey: 'morning',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // بطاقة أذكار المساء الكبيرة
                  _buildAthkarHeroCard(
                    context: context,
                    title: 'أذكار المساء',
                    subtitle: 'سكينة وأمان لليلتك من بعد العصر حتى الصباح',
                    countText: '${AthkarData.eveningAthkar.length} ذكرًا مباركًا',
                    icon: Icons.nightlight_round,
                    gradientColors: [const Color(0xFF3B82F6), const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
                    isHighlight: !isMorning,
                    onTap: () async {
                      final lastIdx = await StorageService.instance.getLibraryLastPosition('evening');
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AthkarReaderScreen(
                              title: 'أذكار المساء',
                              athkarList: AthkarData.eveningAthkar,
                              isMorning: false,
                              settingsController: settingsController,
                              initialIndex: (lastIdx - 1).clamp(0, AthkarData.eveningAthkar.length - 1),
                              sectionKey: 'evening',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // بطاقة أذكار بعد الصلاة المفروضة
                  _buildAthkarHeroCard(
                    context: context,
                    title: 'أذكار بعد الصلاة',
                    subtitle: 'الاستغفار والتسبيح والتهليل وآية الكرسي والمعوذات عقب كل فريضة',
                    countText: '${PostPrayerAthkarData.postPrayerAthkar.length} ذكراً مأثوراً',
                    icon: Icons.mosque_rounded,
                    gradientColors: [const Color(0xFF7E22CE), const Color(0xFF581C87), const Color(0xFF3B0764)],
                    isHighlight: false,
                    onTap: () async {
                      final lastIdx = await StorageService.instance.getLibraryLastPosition('post_prayer');
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AthkarReaderScreen(
                              title: 'أذكار بعد الصلاة',
                              athkarList: PostPrayerAthkarData.postPrayerAthkar,
                              isMorning: false,
                              settingsController: settingsController,
                              initialIndex: (lastIdx - 1).clamp(0, PostPrayerAthkarData.postPrayerAthkar.length - 1),
                              sectionKey: 'post_prayer',
                              customPrimaryColor: const Color(0xFF6B21A8),
                              customGradientColors: const [
                                Color(0xFF581C87),
                                Color(0xFF7E22CE),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // ================= قسم القرآن الكريم =================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D5C3A).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF0D5C3A), size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'القرآن الكريم',
                        style: AppTheme.getCairoFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // جزء عمّ (الجزء الثلاثون)
                      Expanded(
                        child: _buildQuranCard(
                          context: context,
                          title: 'جزء عمّ',
                          partText: 'الجزء الثلاثون',
                          pagesText: '٢٣ صفحة • ص ٥٨٢ إلى ٦٠٤',
                          icon: Icons.menu_book_rounded,
                          gradientColors: const [Color(0xFF064E3B), Color(0xFF047857)],
                          badge: 'الجزء ٣٠',
                          onTap: () async {
                            final lastPage = await StorageService.instance.getLibraryLastPosition('juz_amma');
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocumentReaderScreen(
                                    title: 'جزء عمّ (القرآن الكريم)',
                                    sectionKey: 'juz_amma',
                                    assetFolder: 'juz_amma',
                                    totalPages: 23,
                                    initialPage: lastPage,
                                    mushafStartPage: 582,
                                    primaryColor: const Color(0xFF0D5C3A),
                                    secondaryColor: const Color(0xFF1B7A50),
                                    pageTitles: const {
                                      1: 'سورة النبأ (ص 582)',
                                      2: 'سورة النبأ (ص 583)',
                                      3: 'سورة النازعات (ص 584)',
                                      4: 'سورة النازعات (ص 585)',
                                      5: 'سورة عبس (ص 586)',
                                      6: 'سورة عبس والتكوير (ص 587)',
                                      7: 'سورة التكوير والانفطار (ص 588)',
                                      8: 'سورة المطففين (ص 589)',
                                      9: 'سورة المطففين والانشقاق (ص 590)',
                                      10: 'سورة الانشقاق والبروج (ص 591)',
                                      11: 'سورة البروج والطارق (ص 592)',
                                      12: 'سورة الطارق والأعلى (ص 593)',
                                      13: 'سورة الأعلى والغاشية (ص 594)',
                                      14: 'سورة الغاشية والفجر (ص 595)',
                                      15: 'سورة الفجر والبلد (ص 596)',
                                      16: 'سورة البلد والشمس (ص 597)',
                                      17: 'سورة الليل والضحى (ص 598)',
                                      18: 'سورة الشرح والتين والعلق (ص 599)',
                                      19: 'سورة العلق والقدر والبينة (ص 600)',
                                      20: 'سورة البينة والزلزلة والعاديات (ص 601)',
                                      21: 'سورة القارعة والتكاثر والعصر (ص 602)',
                                      22: 'سورة الفيل وقريش والماعون (ص 603)',
                                      23: 'المعوذات وسورة الناس (ص 604)',
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // جزء تبارك (الجزء التاسع والعشرون)
                      Expanded(
                        child: _buildQuranCard(
                          context: context,
                          title: 'جزء تبارك',
                          partText: 'الجزء التاسع والعشرون',
                          pagesText: '٢٠ صفحة • ص ٥٦٢ إلى ٥٨١',
                          icon: Icons.menu_book_sharp,
                          gradientColors: const [Color(0xFF164E63), Color(0xFF0E7490)],
                          badge: 'الجزء ٢٩',
                          onTap: () async {
                            final lastPage = await StorageService.instance.getLibraryLastPosition('juz_tabarak');
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocumentReaderScreen(
                                    title: 'جزء تبارك (القرآن الكريم)',
                                    sectionKey: 'juz_tabarak',
                                    assetFolder: 'juz_tabarak',
                                    totalPages: 20,
                                    initialPage: lastPage,
                                    mushafStartPage: 562,
                                    primaryColor: const Color(0xFF0F766E),
                                    secondaryColor: const Color(0xFF14B8A6),
                                    pageTitles: const {
                                      1: 'سورة الملك (ص 562)',
                                      2: 'سورة الملك (ص 563)',
                                      3: 'سورة الملك والقلم (ص 564)',
                                      4: 'سورة القلم (ص 565)',
                                      5: 'سورة الحاقة (ص 566)',
                                      6: 'سورة الحاقة والمعارج (ص 567)',
                                      7: 'سورة المعارج (ص 568)',
                                      8: 'سورة المعارج ونوح (ص 569)',
                                      9: 'سورة نوح (ص 570)',
                                      10: 'سورة نوح والجن (ص 571)',
                                      11: 'سورة الجن (ص 572)',
                                      12: 'سورة الجن والمزمل (ص 573)',
                                      13: 'سورة المزمل والمدثر (ص 574)',
                                      14: 'سورة المدثر (ص 575)',
                                      15: 'سورة المدثر والقيامة (ص 576)',
                                      16: 'سورة القيامة والإنسان (ص 577)',
                                      17: 'سورة الإنسان (ص 578)',
                                      18: 'سورة الإنسان والمرسلات (ص 579)',
                                      19: 'سورة المرسلات (ص 580)',
                                      20: 'سورة المرسلات (ص 581)',
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ================= قسم محاسبة النفس اليومية =================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.balance_rounded, color: AppTheme.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'محاسبة النفس اليومية',
                        style: AppTheme.getCairoFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // صف بطاقتي الصلوات وماذا قدمت اليوم
                  Row(
                    children: [
                      // محاسبة الصلوات والسنن
                      Expanded(
                        child: AnimatedBuilder(
                          animation: accountabilityController,
                          builder: (context, _) {
                            final count = accountabilityController.currentPrayerLog?.totalPrayedCount ?? 0;
                            return _buildSectionCard(
                              context: context,
                              title: 'محاسبة الصلوات والسنن',
                              subtitle: 'متابعة الفروض الـ 5 وسنن الرواتب',
                              icon: Icons.mosque_outlined,
                              color: AppTheme.primaryGreen,
                              badge: '$count/5 صلوات',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PrayerAccountabilityScreen(
                                      controller: accountabilityController,
                                      settingsController: settingsController,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // محاسبة الأعمال اليومية
                      Expanded(
                        child: AnimatedBuilder(
                          animation: accountabilityController,
                          builder: (context, _) {
                            final count = accountabilityController.currentDeedsLog?.completedCount ?? 0;
                            return _buildSectionCard(
                              context: context,
                              title: 'ماذا قدمت اليوم؟',
                              subtitle: 'القرآن، الصدقة، صلة الرحم، الاستغفار',
                              icon: Icons.checklist_rounded,
                              color: Colors.teal,
                              badge: '$count عمل منجز',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DailyDeedsScreen(
                                      controller: accountabilityController,
                                      settingsController: settingsController,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // بطاقة مميزة: وقفة مع نفسك – المراجعة اليومية
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WaqfaScreen(
                            controller: accountabilityController,
                            settingsController: settingsController,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1B3B2B), const Color(0xFF10281D)]
                              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldAccent.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.goldAccent.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.self_improvement_rounded,
                              color: AppTheme.goldAccent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'وقفة مع نفسك – المراجعة اليومية',
                                      style: AppTheme.getCairoFont(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star_rounded, size: 16, color: AppTheme.goldAccent),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'جلسة مراجعة ومحاسبة ذاتية هادئة في نهاية اليوم وتخطيط للغد',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppTheme.goldAccent),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= قسم الأحاديث النبوية الشريفة وعداد الأذكار =================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.library_books_rounded, color: AppTheme.goldAccent, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الأحاديث النبوية وعداد الأذكار',
                        style: AppTheme.getCairoFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // بطاقة الأربعون النووية
                  _buildArbaeenCard(
                    context: context,
                    title: 'الأربعون النووية',
                    subtitle: 'جوامع الكلم من أحاديث المصطفى ﷺ للإمام النووي رحمه الله (٣٢ صفحة كاملة)',
                    badge: 'دار السلام',
                    onTap: () async {
                      final lastPage = await StorageService.instance.getLibraryLastPosition('arbaeen');
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentReaderScreen(
                              title: 'الأربعون النووية',
                              sectionKey: 'arbaeen',
                              assetFolder: 'arbaeen',
                              totalPages: 32,
                              initialPage: lastPage,
                              primaryColor: const Color(0xFF991B1B),
                              secondaryColor: const Color(0xFFDC2626),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // المسبحة الإلكترونية المطورة
                      Expanded(
                        child: _buildSectionCard(
                          context: context,
                          title: 'المسبحة وعداد الأذكار',
                          subtitle: 'تسبيح، تحميد، تكبير، استغفار',
                          icon: Icons.fingerprint_rounded,
                          color: AppTheme.primaryGreen,
                          badge: 'مطور',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TasbeehScreen(
                                  settingsController: settingsController,
                                  accountabilityController: accountabilityController,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // صحيح البخاري وحديث اليوم
                      Expanded(
                        child: _buildSectionCard(
                          context: context,
                          title: 'صحيح البخاري وحديث اليوم',
                          subtitle: 'أحاديث نبوية صحيحة بشروحها',
                          icon: Icons.menu_book_rounded,
                          color: Colors.amber.shade800,
                          badge: 'حديث اليوم',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HadithScreen(
                                  controller: accountabilityController,
                                  settingsController: settingsController,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // صف بطاقة الإنجازات وفضائل الذكر
                  Row(
                    children: [
                      // إنجازاتي اليومية
                      Expanded(
                        child: _buildSectionCard(
                          context: context,
                          title: 'إنجازاتي اليومية',
                          subtitle: 'تقارير يومية وأسبوعية وشهرية',
                          icon: Icons.insights_rounded,
                          color: Colors.indigo,
                          badge: 'إحصائيات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AchievementsScreen(
                                  controller: accountabilityController,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // فضائل الذكر
                      Expanded(
                        child: _buildSectionCard(
                          context: context,
                          title: 'فضائل الذكر',
                          subtitle: 'بركات وفوائد الأذكار النبوية',
                          icon: Icons.auto_awesome,
                          color: AppTheme.goldAccentDark,
                          badge: 'فوائد',
                          onTap: () => _showVirtuesDialog(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // بطاقة خاصة: دعاء لمن أنشأ التطبيق وقارئيه
                  InkWell(
                    onTap: () => _showDuaaDialog(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1C2C24), const Color(0xFF121F19)]
                              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.goldAccent.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldAccent.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.goldAccent.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppTheme.goldAccent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'دعاء لمن أنشأ التطبيق وقارئيه',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'دعاء مستجاب بظهر الغيب يجمعنا في الفردوس الأعلى',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppTheme.goldAccent),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthkarHeroCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String countText,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isHighlight,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: isHighlight
              ? Border.all(color: AppTheme.goldAccent, width: 2)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTheme.getArabicFont(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isHighlight) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'الوقت الحالي',
                            style: AppTheme.getCairoFont(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          countText,
                          style: AppTheme.getCairoFont(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'ابدأ القراءة',
                            style: AppTheme.getCairoFont(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_back_ios_rounded, size: 14, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranCard({
    required BuildContext context,
    required String title,
    required String partText,
    required String pagesText,
    required IconData icon,
    required List<Color> gradientColors,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldAccent.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.getArabicFont(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              partText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pagesText,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'قراءة المصحف',
                  style: AppTheme.getCairoFont(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldAccentLight,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 11,
                  color: AppTheme.goldAccentLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArbaeenCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F1D1D), Color(0xFF991B1B), Color(0xFFB91C1C)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldAccent.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
              ),
              child: const Icon(
                Icons.bookmarks_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTheme.getArabicFont(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: AppTheme.goldAccentLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(14),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: AppTheme.getCairoFont(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: AppTheme.getCairoFont(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.getCairoFont(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
