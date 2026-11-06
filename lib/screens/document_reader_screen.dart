import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

enum DocumentReadingTheme {
  parchment,
  light,
  dark,
}

class DocumentReaderScreen extends StatefulWidget {
  final String title;
  final String sectionKey;
  final String assetFolder;
  final int totalPages;
  final int initialPage;
  final int? mushafStartPage; // رقم صفحة البداية في المصحف الشريف إن كان جزءاً قرآنياً
  final Color primaryColor;
  final Color secondaryColor;
  final Map<int, String>? pageTitles; // عناوين الصفحات أو السور

  const DocumentReaderScreen({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.assetFolder,
    required this.totalPages,
    this.initialPage = 1,
    this.mushafStartPage,
    this.primaryColor = AppTheme.primaryGreen,
    this.secondaryColor = AppTheme.primaryGreenLight,
    this.pageTitles,
  });

  @override
  State<DocumentReaderScreen> createState() => _DocumentReaderScreenState();
}

class _DocumentReaderScreenState extends State<DocumentReaderScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _isFullscreen = false;
  DocumentReadingTheme _readingTheme = DocumentReadingTheme.parchment;
  final Map<int, TransformationController> _transformControllers = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, widget.totalPages);
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    // إعادة شريط الحالة عند الخروج
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  TransformationController _getTransformController(int index) {
    return _transformControllers.putIfAbsent(index, () => TransformationController());
  }

  void _onPageChanged(int index) {
    final newPage = index + 1;
    setState(() {
      _currentPage = newPage;
    });
    // حفظ التقدم تلقائياً
    StorageService.instance.saveLibraryLastPosition(widget.sectionKey, newPage);
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _jumpToPage(int page) {
    final target = page.clamp(1, widget.totalPages);
    _pageController.jumpToPage(target - 1);
  }

  void _showBookmarkSaved() {
    StorageService.instance.saveLibraryLastPosition(widget.sectionKey, _currentPage);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bookmark_added, color: AppTheme.goldAccent),
            const SizedBox(width: 10),
            Text(
              'تم حفظ العلامة عند صفحة $_currentPage',
              style: AppTheme.getArabicFont(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showJumpToPageDialog() {
    final controller = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'الانتقال إلى صفحة',
              style: AppTheme.getArabicFont(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أدخل رقم الصفحة (من 1 إلى ${widget.totalPages}):',
                  style: AppTheme.getArabicFont(fontSize: 14),
                ),
                if (widget.mushafStartPage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '(الصفحات في المصحف: ${widget.mushafStartPage} - ${widget.mushafStartPage! + widget.totalPages - 1})',
                    style: AppTheme.getArabicFont(fontSize: 13, color: AppTheme.goldAccentDark),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'رقم الصفحة',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: AppTheme.getArabicFont(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final input = int.tryParse(controller.text.trim());
                  if (input != null) {
                    // إذا أدخل رقم صفحة المصحف مباشرة
                    if (widget.mushafStartPage != null &&
                        input >= widget.mushafStartPage! &&
                        input < widget.mushafStartPage! + widget.totalPages) {
                      _jumpToPage(input - widget.mushafStartPage! + 1);
                    } else {
                      _jumpToPage(input);
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'انتقال',
                  style: AppTheme.getArabicFont(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThumbnailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'فهرس الصفحات (${widget.totalPages} صفحة)',
                        style: AppTheme.getArabicFont(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: widget.totalPages,
                    itemBuilder: (context, idx) {
                      final pageNum = idx + 1;
                      final isCurrent = pageNum == _currentPage;
                      final title = widget.pageTitles?[pageNum];

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _jumpToPage(pageNum);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent ? AppTheme.goldAccent : Colors.grey.withValues(alpha: 0.25),
                              width: isCurrent ? 2.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isCurrent ? 0.15 : 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/${widget.assetFolder}/page_$pageNum.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppTheme.primaryGreen.withValues(alpha: 0.9)
                                          : Colors.black.withValues(alpha: 0.75),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'ص $pageNum',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (title != null)
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
                                          ),
                                        if (widget.mushafStartPage != null)
                                          Text(
                                            'مصحف ${widget.mushafStartPage! + pageNum - 1}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.goldAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.bookmark, size: 14, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBgColor() {
    switch (_readingTheme) {
      case DocumentReadingTheme.parchment:
        return const Color(0xFFFBF8EE);
      case DocumentReadingTheme.light:
        return Colors.white;
      case DocumentReadingTheme.dark:
        return const Color(0xFF141414);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageTitle = widget.pageTitles?[_currentPage];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _getBgColor(),
        appBar: _isFullscreen
            ? null
            : AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.primaryColor, widget.secondaryColor],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
                elevation: 3,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTheme.getArabicFont(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (pageTitle != null)
                      Text(
                        pageTitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.goldAccentLight),
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'حفظ علامة',
                    icon: const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: _showBookmarkSaved,
                  ),
                  IconButton(
                    tooltip: 'فهرس الصفحات',
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                    onPressed: _showThumbnailsModal,
                  ),
                  IconButton(
                    tooltip: 'انتقال إلى صفحة',
                    icon: const Icon(Icons.find_in_page_outlined, color: Colors.white),
                    onPressed: _showJumpToPageDialog,
                  ),
                  IconButton(
                    tooltip: 'ملء الشاشة',
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: _toggleFullscreen,
                  ),
                  PopupMenuButton<DocumentReadingTheme>(
                    icon: const Icon(Icons.color_lens_outlined, color: Colors.white),
                    tooltip: 'سمة القراءة',
                    onSelected: (theme) => setState(() => _readingTheme = theme),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: DocumentReadingTheme.parchment,
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, color: Color(0xFFC49A45)),
                            SizedBox(width: 8),
                            Text('لون الورق المصحفي'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: DocumentReadingTheme.light,
                        child: Row(
                          children: [
                            Icon(Icons.light_mode, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('أبيض ناصع'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: DocumentReadingTheme.dark,
                        child: Row(
                          children: [
                            Icon(Icons.dark_mode, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('الوضع الليلي'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // النقر في وضع ملء الشاشة يظهر/يخفي الأشرطة
                if (_isFullscreen) {
                  _toggleFullscreen();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.totalPages,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final pageNum = index + 1;
                  final transformController = _getTransformController(index);

                  return InteractiveViewer(
                    transformationController: transformController,
                    minScale: 1.0,
                    maxScale: 4.5,
                    child: Center(
                      child: Container(
                        margin: _isFullscreen
                            ? EdgeInsets.zero
                            : const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/${widget.assetFolder}/page_$pageNum.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: 12),
                                  Text(
                                    'تعذر عرض الصفحة $pageNum',
                                    style: AppTheme.getArabicFont(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // زر الخروج السريع من ملء الشاشة
            if (_isFullscreen)
              Positioned(
                top: 36,
                right: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: _toggleFullscreen,
                    ),
                  ),
                ),
              ),

            // شريط المعلومات والتحكم السفلي (يختفي في ملء الشاشة)
            if (!_isFullscreen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر الصفحة السابقة
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 18),
                              tooltip: 'الصفحة السابقة',
                              onPressed: _currentPage > 1
                                  ? () => _jumpToPage(_currentPage - 1)
                                  : null,
                            ),

                            // رقم الصفحة الحالي وتفاصيل المصحف
                            InkWell(
                              onTap: _showJumpToPageDialog,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'صفحة $_currentPage من ${widget.totalPages}',
                                      style: AppTheme.getArabicFont(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: widget.primaryColor,
                                      ),
                                    ),
                                    if (widget.mushafStartPage != null)
                                      Text(
                                        'المصحف: صفحة ${widget.mushafStartPage! + _currentPage - 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // زر الصفحة التالية
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 18),
                              tooltip: 'الصفحة التالية',
                              onPressed: _currentPage < widget.totalPages
                                  ? () => _jumpToPage(_currentPage + 1)
                                  : null,
                            ),
                          ],
                        ),

                        // شريط التمرير السريع
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: widget.primaryColor,
                            inactiveTrackColor: widget.primaryColor.withValues(alpha: 0.2),
                            thumbColor: widget.primaryColor,
                            overlayColor: widget.primaryColor.withValues(alpha: 0.15),
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: _currentPage.toDouble(),
                            min: 1.0,
                            max: widget.totalPages.toDouble(),
                            divisions: widget.totalPages > 1 ? widget.totalPages - 1 : 1,
                            onChanged: (val) {
                              _jumpToPage(val.round());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
