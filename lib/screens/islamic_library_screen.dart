import 'package:flutter/material.dart';
import '../data/athkar_data.dart';
import '../data/post_prayer_athkar_data.dart';
import '../services/storage_service.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import 'athkar_reader_screen.dart';
import 'document_reader_screen.dart';

class IslamicLibraryScreen extends StatefulWidget {
  final SettingsController settingsController;

  const IslamicLibraryScreen({
    super.key,
    required this.settingsController,
  });

  @override
  State<IslamicLibraryScreen> createState() => _IslamicLibraryScreenState();
}

class _IslamicLibraryScreenState extends State<IslamicLibraryScreen> {
  // تتبع آخر صفحة / موضع لكل قسم
  int _lastMorningThikr = 1;
  int _lastEveningThikr = 1;
  int _lastPostPrayerThikr = 1;
  int _lastArbaeenPage = 1;
  int _lastJuzAmmaPage = 1;
  int _lastJuzTabarakPage = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    final storage = StorageService.instance;
    final morning = await storage.getLibraryLastPosition('morning');
    final evening = await storage.getLibraryLastPosition('evening');
    final postPrayer = await storage.getLibraryLastPosition('post_prayer');
    final arbaeen = await storage.getLibraryLastPosition('arbaeen');
    final juzAmma = await storage.getLibraryLastPosition('juz_amma');
    final juzTabarak = await storage.getLibraryLastPosition('juz_tabarak');

    if (mounted) {
      setState(() {
        _lastMorningThikr = morning;
        _lastEveningThikr = evening;
        _lastPostPrayerThikr = postPrayer;
        _lastArbaeenPage = arbaeen;
        _lastJuzAmmaPage = juzAmma;
        _lastJuzTabarakPage = juzTabarak;
        _isLoading = false;
      });
    }
  }

  void _openMorningAthkar({int? startIdx}) {
    final idx = startIdx ?? (_lastMorningThikr - 1);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AthkarReaderScreen(
          title: 'أذكار الصباح',
          athkarList: AthkarData.morningAthkar,
          isMorning: true,
          settingsController: widget.settingsController,
          initialIndex: idx,
          sectionKey: 'morning',
        ),
      ),
    ).then((_) => _loadPositions());
  }

  void _openEveningAthkar({int? startIdx}) {
    final idx = startIdx ?? (_lastEveningThikr - 1);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AthkarReaderScreen(
          title: 'أذكار المساء',
          athkarList: AthkarData.eveningAthkar,
          isMorning: false,
          settingsController: widget.settingsController,
          initialIndex: idx,
          sectionKey: 'evening',
        ),
      ),
    ).then((_) => _loadPositions());
  }

  void _openPostPrayerAthkar({int? startIdx}) {
    final idx = startIdx ?? (_lastPostPrayerThikr - 1);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AthkarReaderScreen(
          title: 'أذكار بعد الصلاة',
          athkarList: PostPrayerAthkarData.postPrayerAthkar,
          isMorning: false,
          settingsController: widget.settingsController,
          initialIndex: idx,
          sectionKey: 'post_prayer',
          customPrimaryColor: const Color(0xFF6B21A8),
          customGradientColors: const [
            Color(0xFF581C87),
            Color(0xFF7E22CE),
          ],
        ),
      ),
    ).then((_) => _loadPositions());
  }

  void _openArbaeen({int? page}) {
    final p = page ?? _lastArbaeenPage;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentReaderScreen(
          title: 'الأربعون النووية',
          sectionKey: 'arbaeen',
          assetFolder: 'arbaeen',
          totalPages: 32,
          initialPage: p,
          primaryColor: const Color(0xFF991B1B), // عنابي فاخر
          secondaryColor: const Color(0xFFDC2626),
        ),
      ),
    ).then((_) => _loadPositions());
  }

  void _openJuzAmma({int? page}) {
    final p = page ?? _lastJuzAmmaPage;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentReaderScreen(
          title: 'جزء عمّ (القرآن الكريم)',
          sectionKey: 'juz_amma',
          assetFolder: 'juz_amma',
          totalPages: 23,
          initialPage: p,
          mushafStartPage: 582,
          primaryColor: const Color(0xFF0D5C3A), // أخضر إسلامي فاخر
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
    ).then((_) => _loadPositions());
  }

  void _openJuzTabarak({int? page}) {
    final p = page ?? _lastJuzTabarakPage;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentReaderScreen(
          title: 'جزء تبارك (القرآن الكريم)',
          sectionKey: 'juz_tabarak',
          assetFolder: 'juz_tabarak',
          totalPages: 20,
          initialPage: p,
          mushafStartPage: 562,
          primaryColor: const Color(0xFF0F766E), // تيل فاخر
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
    ).then((_) => _loadPositions());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF047857)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          elevation: 2,
          title: Text(
            'المكتبة الإسلامية',
            style: AppTheme.getArabicFont(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: 'تحديث المواضع',
              onPressed: _loadPositions,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // بطاقة الترويسة الأنيقة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.primaryGreenLight.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories,
                            size: 36,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مكتبة المسلم اليومية',
                                style: AppTheme.getArabicFont(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'القرآن الكريم، الأحاديث النبوية الشريفة، وأذكار اليوم والليلة وما بعد الصلاة بدقة وتشكيل كامل.',
                                style: AppTheme.getArabicFont(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // عنوان قسم الأذكار النبوية
                  _buildSectionHeader('الأذكار النبوية والمأثورات', Icons.nights_stay_outlined),

                  const SizedBox(height: 12),

                  // 1. أذكار الصباح
                  _buildLibraryCard(
                    title: 'أذكار الصباح',
                    subtitle: '٣٢ ذكراً مباركاً لبدء يومك بحفظ الله ورعايته',
                    badge: 'الصباح',
                    badgeColor: const Color(0xFFD97706),
                    icon: Icons.wb_sunny_rounded,
                    gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
                    lastReadText: _lastMorningThikr > 1
                        ? 'آخر قراءة: الذكر $_lastMorningThikr من ٣٢'
                        : 'لم تبدأ بعد',
                    progressPercent: _lastMorningThikr / 32.0,
                    onTap: () => _openMorningAthkar(),
                    onResume: _lastMorningThikr > 1 ? () => _openMorningAthkar() : null,
                  ),

                  const SizedBox(height: 14),

                  // 2. أذكار المساء
                  _buildLibraryCard(
                    title: 'أذكار المساء',
                    subtitle: '٣٢ ذكراً مباركاً لتحصين نفسك في المساء والليل',
                    badge: 'المساء',
                    badgeColor: const Color(0xFF4338CA),
                    icon: Icons.nights_stay_rounded,
                    gradientColors: const [Color(0xFF312E81), Color(0xFF4338CA)],
                    lastReadText: _lastEveningThikr > 1
                        ? 'آخر قراءة: الذكر $_lastEveningThikr من ٣٢'
                        : 'لم تبدأ بعد',
                    progressPercent: _lastEveningThikr / 32.0,
                    onTap: () => _openEveningAthkar(),
                    onResume: _lastEveningThikr > 1 ? () => _openEveningAthkar() : null,
                  ),

                  const SizedBox(height: 14),

                  // 3. أذكار بعد الصلاة المفروضة
                  _buildLibraryCard(
                    title: 'أذكار بعد الصلاة',
                    subtitle: 'أذكار الاستغفار والتسبيح والتهليل وآية الكرسي والمعوذات عقب كل فريضة',
                    badge: 'دبر الصلاة',
                    badgeColor: const Color(0xFF7E22CE),
                    icon: Icons.mosque_rounded,
                    gradientColors: const [Color(0xFF581C87), Color(0xFF7E22CE)],
                    lastReadText: _lastPostPrayerThikr > 1
                        ? 'آخر قراءة: الذكر $_lastPostPrayerThikr من ١٤'
                        : '١٤ ذكراً مأثوراً',
                    progressPercent: _lastPostPrayerThikr / 14.0,
                    onTap: () => _openPostPrayerAthkar(),
                    onResume: _lastPostPrayerThikr > 1 ? () => _openPostPrayerAthkar() : null,
                  ),

                  const SizedBox(height: 28),

                  // عنوان قسم القرآن الكريم
                  _buildSectionHeader('القرآن الكريم', Icons.menu_book_rounded),

                  const SizedBox(height: 12),

                  // 4. جزء عمّ
                  _buildLibraryCard(
                    title: 'جزء عمّ (الجزء الثلاثون)',
                    subtitle: '٢٣ صفحة مصحفية كاملة طبق الأصل (الصفحات ٥٨٢ إلى ٦٠٤)',
                    badge: 'الجزء ٣٠',
                    badgeColor: const Color(0xFF047857),
                    icon: Icons.auto_stories_rounded,
                    gradientColors: const [Color(0xFF064E3B), Color(0xFF047857)],
                    lastReadText: 'وصلت إلى صفحة $_lastJuzAmmaPage من ٢٣ (ص ${581 + _lastJuzAmmaPage} بالمصحف)',
                    progressPercent: _lastJuzAmmaPage / 23.0,
                    onTap: () => _openJuzAmma(),
                    onResume: () => _openJuzAmma(),
                  ),

                  const SizedBox(height: 14),

                  // 5. جزء تبارك
                  _buildLibraryCard(
                    title: 'جزء تبارك (الجزء التاسع والعشرون)',
                    subtitle: '٢٠ صفحة مصحفية كاملة طبق الأصل (الصفحات ٥٦٢ إلى ٥٨١)',
                    badge: 'الجزء ٢٩',
                    badgeColor: const Color(0xFF0E7490),
                    icon: Icons.menu_book_sharp,
                    gradientColors: const [Color(0xFF164E63), Color(0xFF0E7490)],
                    lastReadText: 'وصلت إلى صفحة $_lastJuzTabarakPage من ٢٠ (ص ${561 + _lastJuzTabarakPage} بالمصحف)',
                    progressPercent: _lastJuzTabarakPage / 20.0,
                    onTap: () => _openJuzTabarak(),
                    onResume: () => _openJuzTabarak(),
                  ),

                  const SizedBox(height: 28),

                  // عنوان قسم السنة النبوية المطهرة
                  _buildSectionHeader('السنة النبوية المطهرة', Icons.library_books_rounded),

                  const SizedBox(height: 12),

                  // 6. الأربعون النووية
                  _buildLibraryCard(
                    title: 'الأربعون النووية',
                    subtitle: 'جوامع الكلم من أحاديث المصطفى ﷺ للإمام النووي (٣٢ صفحة كاملة)',
                    badge: 'دار السلام',
                    badgeColor: const Color(0xFFB91C1C),
                    icon: Icons.bookmarks_rounded,
                    gradientColors: const [Color(0xFF7F1D1D), Color(0xFFB91C1C)],
                    lastReadText: 'وصلت إلى صفحة $_lastArbaeenPage من ٣٢',
                    progressPercent: _lastArbaeenPage / 32.0,
                    onTap: () => _openArbaeen(),
                    onResume: () => _openArbaeen(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.goldAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.getArabicFont(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(
            color: Colors.grey.withValues(alpha: 0.25),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required List<Color> gradientColors,
    required String lastReadText,
    required double progressPercent,
    required VoidCallback onTap,
    VoidCallback? onResume,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // الشريط العلوي الملون
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.getArabicFont(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
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
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى السفلي ومؤشر الموضع
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 16,
                              color: AppTheme.goldAccentDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lastReadText,
                              style: AppTheme.getArabicFont(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (onResume != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gradientColors.first,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 16),
                            label: Text(
                              'متابعة',
                              style: AppTheme.getArabicFont(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: onResume,
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // شريط التقدم
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent.clamp(0.0, 1.0),
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(gradientColors.first),
                        minHeight: 4,
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
  }
}
