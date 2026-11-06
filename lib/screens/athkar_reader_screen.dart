import 'package:flutter/material.dart';
import '../models/thikr_model.dart';
import '../theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../services/storage_service.dart';

class AthkarReaderScreen extends StatefulWidget {
  final String title;
  final List<Thikr> athkarList;
  final bool isMorning;
  final SettingsController settingsController;
  final int initialIndex;
  final String? sectionKey;
  final List<Color>? customGradientColors;
  final Color? customPrimaryColor;

  const AthkarReaderScreen({
    super.key,
    required this.title,
    required this.athkarList,
    required this.isMorning,
    required this.settingsController,
    this.initialIndex = 0,
    this.sectionKey,
    this.customGradientColors,
    this.customPrimaryColor,
  });

  @override
  State<AthkarReaderScreen> createState() => _AthkarReaderScreenState();
}

class _AthkarReaderScreenState extends State<AthkarReaderScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<int> _currentCounts; // عداد التكرار المنجز لكل ذكر
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.athkarList.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.athkarList.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _currentCounts = List<int>.filled(widget.athkarList.length, 0);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final currentThikr = widget.athkarList[_currentIndex];
    final currentCount = _currentCounts[_currentIndex];

    if (currentCount < currentThikr.targetCount) {
      widget.settingsController.triggerTapFeedback();
      _pulseController.forward().then((_) => _pulseController.reverse());

      setState(() {
        _currentCounts[_currentIndex] = currentCount + 1;
      });

      // التحقق من اكتمال هذا الذكر
      if (_currentCounts[_currentIndex] >= currentThikr.targetCount) {
        widget.settingsController.triggerCompletionFeedback();

        if (widget.settingsController.autoAdvanceEnabled) {
          Future.delayed(const Duration(milliseconds: 320), () {
            if (mounted) {
              if (_currentIndex < widget.athkarList.length - 1) {
                _nextThikr();
              } else {
                _showCompletionDialog();
              }
            }
          });
        }
      }
    }
  }

  void _resetCurrentCount() {
    setState(() {
      _currentCounts[_currentIndex] = 0;
    });
  }

  void _nextThikr() {
    if (_currentIndex < widget.athkarList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _prevThikr() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _jumpToThikr(int index) {
    Navigator.of(context).pop();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showThikrListSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (_, scrollController) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'فهرس ${widget.title}',
                          style: AppTheme.getCairoFont(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.primaryGreen,
                          ),
                        ),
                        Text(
                          '${widget.athkarList.length} ذكرًا',
                          style: AppTheme.getCairoFont(
                            fontSize: 14,
                            color: AppTheme.goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.athkarList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final thikr = widget.athkarList[index];
                        final isDone = _currentCounts[index] >= thikr.targetCount;
                        final isCurrent = index == _currentIndex;

                        return InkWell(
                          onTap: () => _jumpToThikr(index),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? (widget.customPrimaryColor ??
                                          (widget.isMorning
                                              ? AppTheme.morningStart
                                              : AppTheme.eveningStart))
                                      .withValues(alpha: 0.12)
                                  : (isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.06)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrent ? AppTheme.goldAccent : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isDone
                                      ? Colors.green
                                      : (isCurrent ? AppTheme.goldAccent : Colors.grey.withValues(alpha: 0.3)),
                                  child: isDone
                                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isCurrent ? Colors.black : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        thikr.text.replaceAll('\n', ' '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.getArabicFont(
                                          fontSize: 16,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'التكرار: ${thikr.countDescription}  |  المكتمل: ${_currentCounts[index]}/${thikr.targetCount}',
                                        style: AppTheme.getCairoFont(
                                          fontSize: 12,
                                          color: isDone ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 70,
                    color: AppTheme.goldAccent,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'تقبّل الله طاعتكم',
                  style: AppTheme.getArabicFont(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'أتممت بحمد الله قراءة ${widget.title} كاملةً.\nجعلها الله حِصنًا لك وحِرزًا من كل سوء، ورزقك خيرها وبركتها.',
                  textAlign: TextAlign.center,
                  style: AppTheme.getCairoFont(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : AppTheme.lightBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ ﴾',
                    textAlign: TextAlign.center,
                    style: AppTheme.getArabicFont(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _currentCounts = List<int>.filled(widget.athkarList.length, 0);
                            _currentIndex = 0;
                            _pageController.jumpToPage(0);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.goldAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'إعادة القراءة',
                          style: AppTheme.getCairoFont(fontSize: 14, color: AppTheme.goldAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'الرئيسية',
                          style: AppTheme.getCairoFont(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  'حجم الخط',
                  textAlign: TextAlign.center,
                  style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
                      textAlign: TextAlign.center,
                      style: AppTheme.getArabicFont(
                        fontSize: widget.settingsController.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.format_size, size: 18),
                        Expanded(
                          child: Slider(
                            value: widget.settingsController.fontSize,
                            min: 16.0,
                            max: 34.0,
                            divisions: 9,
                            activeColor: AppTheme.goldAccent,
                            label: widget.settingsController.fontSize.round().toString(),
                            onChanged: (val) {
                              setDialogState(() {
                                widget.settingsController.setFontSize(val);
                              });
                              setState(() {});
                            },
                          ),
                        ),
                        const Icon(Icons.format_size, size: 28),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('تم', style: AppTheme.getCairoFont(color: AppTheme.goldAccent)),
                  ),
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
    final primaryThemeColor = widget.customPrimaryColor ??
        (widget.isMorning ? AppTheme.morningStart : AppTheme.eveningStart);
    final secondaryThemeColor = widget.customPrimaryColor ??
        (widget.isMorning ? AppTheme.morningEnd : AppTheme.eveningEnd);

    final currentThikr = widget.athkarList[_currentIndex];
    final currentCount = _currentCounts[_currentIndex];
    final isCurrentCompleted = currentCount >= currentThikr.targetCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.customGradientColors ??
                    (widget.isMorning
                        ? [const Color(0xFFD97706), const Color(0xFFB45309)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)]),
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: AppTheme.getArabicFont(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.format_size),
              tooltip: 'تغيير حجم الخط',
              onPressed: _showFontSizeDialog,
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              tooltip: 'فهرس الأذكار',
              onPressed: _showThikrListSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط التقدم العلوي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Text(
                    'الذكر ${_currentIndex + 1} من ${widget.athkarList.length}',
                    style: AppTheme.getCairoFont(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.athkarList.length,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isMorning ? AppTheme.morningStart : AppTheme.eveningEnd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // البطاقة الرئيسية التفاعلية
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.athkarList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (widget.sectionKey != null) {
                    StorageService.instance.saveLibraryLastPosition(widget.sectionKey!, index + 1);
                  }
                },
                itemBuilder: (context, index) {
                  final thikr = widget.athkarList[index];
                  final count = _currentCounts[index];
                  final isDone = count >= thikr.targetCount;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleTap,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 280),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: thikr.isSpecialDuaa
                                      ? AppTheme.goldAccent
                                      : (isDone
                                          ? Colors.green.withValues(alpha: 0.6)
                                          : (isDark
                                              ? AppTheme.goldAccent.withValues(alpha: 0.18)
                                              : primaryThemeColor.withValues(alpha: 0.15))),
                                  width: thikr.isSpecialDuaa ? 2.5 : (isDone ? 2 : 1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: thikr.isSpecialDuaa
                                        ? AppTheme.goldAccent.withValues(alpha: 0.15)
                                        : (isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.04)),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // شارة التكرار ونوع التكرار أعلى البطاقة
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // شارة نوع التكرار
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: thikr.isSpecialDuaa
                                              ? AppTheme.goldAccent.withValues(alpha: 0.15)
                                              : (isDark ? Colors.white10 : primaryThemeColor.withValues(alpha: 0.08)),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: thikr.isSpecialDuaa
                                                ? AppTheme.goldAccent
                                                : primaryThemeColor.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              thikr.isSpecialDuaa ? Icons.favorite_rounded : Icons.repeat_rounded,
                                              size: 16,
                                              color: thikr.isSpecialDuaa ? AppTheme.goldAccent : primaryThemeColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              thikr.countDescription,
                                              style: AppTheme.getCairoFont(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: thikr.isSpecialDuaa ? AppTheme.goldAccent : primaryThemeColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // المصدر
                                      if (thikr.source != null)
                                        Text(
                                          thikr.source!,
                                          style: AppTheme.getCairoFont(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),

                                  if (thikr.isSpecialDuaa) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppTheme.goldAccent, Color(0xFFF59E0B)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            'دعاء ختامي لمن أنشأ التطبيق وقارئيه',
                                            style: AppTheme.getCairoFont(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  // نص الذكر الشريف
                                  SelectableText(
                                    thikr.text,
                                    textAlign: TextAlign.center,
                                    style: AppTheme.getArabicFont(
                                      fontSize: widget.settingsController.fontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.85,
                                      color: isDark ? const Color(0xFFF0FDF4) : const Color(0xFF1F2937),
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  // خط زخرفي يفصل نص الذكر عن شرح الفضل
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                AppTheme.goldAccent.withValues(alpha: 0.5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '✦ ۞ ✦',
                                          style: TextStyle(
                                            color: AppTheme.goldAccent,
                                            fontSize: 13,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.goldAccent.withValues(alpha: 0.5),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // بطاقة فضل الذكر تحت الخط
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : (widget.isMorning ? AppTheme.morningCardBg : AppTheme.eveningCardBg),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.goldAccent.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.auto_awesome,
                                              size: 16,
                                              color: AppTheme.goldAccent,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'فضل هذا الذكر وعدد تكراره (${thikr.countDescription}):',
                                              style: AppTheme.getCairoFont(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.goldAccent : const Color(0xFF854D0E),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          thikr.reward,
                                          style: AppTheme.getArabicFont(
                                            fontSize: 15,
                                            height: 1.6,
                                            color: isDark ? Colors.white70 : const Color(0xFF374151),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // لوحة العداد التفاعلية السفلية (الضغط على الشاشة ينحسب له تكرار)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر السابق
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded), // في الـ RTL السهم يشير للسابق
                      tooltip: 'الذكر السابق',
                      onPressed: _currentIndex > 0 ? _prevThikr : null,
                    ),

                    // الدائرة التفاعلية الكبيرة للعداد
                    GestureDetector(
                      onTap: _handleTap,
                      child: Container(
                        width: 140,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrentCompleted
                                ? [Colors.green.shade600, Colors.green.shade800]
                                : [primaryThemeColor, secondaryThemeColor],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: (isCurrentCompleted ? Colors.green : primaryThemeColor).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCurrentCompleted ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCurrentCompleted
                                      ? 'اكتمل الذكر'
                                      : '${currentThikr.targetCount - currentCount} متبقٍ',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$currentCount / ${currentThikr.targetCount}',
                                  style: AppTheme.getCairoFont(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // زر إعادة ضبط العداد لهذا الذكر
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'إعادة ضبط هذا الذكر',
                      onPressed: currentCount > 0 ? _resetCurrentCount : null,
                    ),

                    // زر التالي
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded), // في الـ RTL السهم يشير للتالي
                      tooltip: 'الذكر التالي',
                      onPressed: _nextThikr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
