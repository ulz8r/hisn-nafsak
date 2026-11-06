import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/accountability_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/hadith_data.dart';
import '../models/hadith_model.dart';

class HadithScreen extends StatefulWidget {
  final AccountabilityController controller;
  final SettingsController settingsController;

  const HadithScreen({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  bool _onlyFavorites = false;
  bool _onlyRead = false;

  void _showHadithDetails(HadithItem hadith) {
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
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
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

                  // راوي الحديث
                  Text(
                    hadith.narrator,
                    style: AppTheme.getCairoFont(
                      fontSize: 13,
                      color: AppTheme.goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // نص الحديث النبوي الشريف
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      hadith.text,
                      textAlign: TextAlign.center,
                      style: AppTheme.getArabicFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // المصدر والباب
                  Text(
                    hadith.source,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hadith.chapter,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),

                  // الفوائد والشرح
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.goldAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'من فوائد الحديث ومعانيه:',
                        style: AppTheme.getCairoFont(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hadith.explanation,
                    style: AppTheme.getArabicFont(
                      fontSize: 15,
                      height: 1.7,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
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
            'صحيح البخاري والأحاديث',
            style: AppTheme.getArabicFont(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final todayHadith = widget.controller.todayHadith;

            // تصفية الأحاديث
            var filteredHadiths = HadithData.bukhariHadiths.where((h) {
              final matchesCategory = _selectedCategory == 'الكل' || h.category == _selectedCategory;
              final matchesSearch = _searchQuery.isEmpty ||
                  h.text.contains(_searchQuery) ||
                  h.narrator.contains(_searchQuery) ||
                  h.chapter.contains(_searchQuery);
              final matchesFav = !_onlyFavorites || widget.controller.favoriteHadithIds.contains(h.id);
              final matchesRead = !_onlyRead || widget.controller.readHadithIds.contains(h.id);

              return matchesCategory && matchesSearch && matchesFav && matchesRead;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بطاقة حديث اليوم البارزة
                        _buildTodayHadithCard(context, isDark, todayHadith),

                        const SizedBox(height: 18),

                        // شريط البحث
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: AppTheme.getCairoFont(),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.search, color: AppTheme.goldAccent),
                              hintText: 'ابحث في الأحاديث أو الرواة أو الأبواب...',
                              hintStyle: AppTheme.getCairoFont(fontSize: 13, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // فلاتر التفضيل والقراءة
                        Row(
                          children: [
                            FilterChip(
                              label: Text('المفضلة ⭐', style: AppTheme.getCairoFont(fontSize: 12)),
                              selected: _onlyFavorites,
                              selectedColor: AppTheme.goldAccent.withValues(alpha: 0.3),
                              onSelected: (val) => setState(() => _onlyFavorites = val),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text('المقروءة ✓', style: AppTheme.getCairoFont(fontSize: 12)),
                              selected: _onlyRead,
                              selectedColor: Colors.green.withValues(alpha: 0.3),
                              onSelected: (val) => setState(() => _onlyRead = val),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // تصنيفات الأحاديث
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: HadithData.categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = HadithData.categories[index];
                              final isSelected = cat == _selectedCategory;
                              return ChoiceChip(
                                label: Text(
                                  cat,
                                  style: AppTheme.getCairoFont(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryGreen,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCategory = cat);
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'قائمة أحاديث صحيح البخاري (${filteredHadiths.length} حديث):',
                          style: AppTheme.getCairoFont(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // قائمة الأحاديث
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hadith = filteredHadiths[index];
                        final isRead = widget.controller.readHadithIds.contains(hadith.id);
                        final isFav = widget.controller.favoriteHadithIds.contains(hadith.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFav
                                  ? AppTheme.goldAccent.withValues(alpha: 0.6)
                                  : Colors.grey.withValues(alpha: 0.15),
                              width: isFav ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showHadithDetails(hadith);
                              if (!isRead) {
                                widget.controller.toggleHadithRead(hadith.id);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          hadith.category,
                                          style: AppTheme.getCairoFont(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                              color: isFav ? AppTheme.goldAccent : Colors.grey,
                                              size: 22,
                                            ),
                                            tooltip: 'المفضلة',
                                            onPressed: () {
                                              widget.settingsController.triggerTapFeedback();
                                              widget.controller.toggleHadithFavorite(hadith.id);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isRead ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                              color: isRead ? Colors.green : Colors.grey,
                                              size: 22,
                                            ),
                                            tooltip: 'تمت القراءة',
                                            onPressed: () {
                                              widget.settingsController.triggerTapFeedback();
                                              widget.controller.toggleHadithRead(hadith.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hadith.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.getArabicFont(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.7,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        hadith.narrator,
                                        style: AppTheme.getCairoFont(fontSize: 11, color: Colors.grey),
                                      ),
                                      Text(
                                        'عرض الشرح والتفاصيل ←',
                                        style: AppTheme.getCairoFont(
                                          fontSize: 11,
                                          color: AppTheme.goldAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredHadiths.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodayHadithCard(BuildContext context, bool isDark, HadithItem hadith) {
    final isRead = widget.controller.readHadithIds.contains(hadith.id);
    final isFav = widget.controller.favoriteHadithIds.contains(hadith.id);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF142C21), const Color(0xFF0F1E17)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldAccent, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withValues(alpha: 0.12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Colors.black87),
                    const SizedBox(width: 4),
                    Text(
                      'حديث اليوم',
                      style: AppTheme.getCairoFont(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFav ? AppTheme.goldAccent : Colors.grey,
                      size: 22,
                    ),
                    onPressed: () => widget.controller.toggleHadithFavorite(hadith.id),
                  ),
                  IconButton(
                    icon: Icon(
                      isRead ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                      color: isRead ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                    onPressed: () => widget.controller.toggleHadithRead(hadith.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hadith.text,
            style: AppTheme.getArabicFont(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.7,
              color: isDark ? Colors.white : AppTheme.primaryGreenDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hadith.narrator,
                style: AppTheme.getCairoFont(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.brown,
                ),
              ),
              InkWell(
                onTap: () => _showHadithDetails(hadith),
                child: Text(
                  'قراءة الشرح والفوائد ←',
                  style: AppTheme.getCairoFont(
                    fontSize: 11,
                    color: AppTheme.goldAccentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
