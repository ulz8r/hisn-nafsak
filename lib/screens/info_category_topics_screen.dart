import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../theme/app_theme.dart';
import 'info_topic_detail_screen.dart';

/// شاشة عرض قائمة الموضوعات المستقلة داخل التصنيف المختار
class InfoCategoryTopicsScreen extends StatefulWidget {
  final InfoCategory category;

  const InfoCategoryTopicsScreen({
    super.key,
    required this.category,
  });

  @override
  State<InfoCategoryTopicsScreen> createState() => _InfoCategoryTopicsScreenState();
}

class _InfoCategoryTopicsScreenState extends State<InfoCategoryTopicsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = widget.category;

    final filteredTopics = _searchQuery.trim().isEmpty
        ? cat.topics
        : cat.topics.where((t) {
            final q = _searchQuery.trim();
            return t.title.contains(q) ||
                (t.subtitle?.contains(q) ?? false) ||
                (t.answerOrBody?.contains(q) ?? false);
          }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: Text(
            cat.title,
            style: AppTheme.getCairoFont(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppTheme.darkCard : cat.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // شريط الترويسة وشريط البحث
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : cat.primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.subtitle,
                    style: AppTheme.getCairoFont(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // حقل البحث السريع في موضوعات التصنيف
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: AppTheme.getCairoFont(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث داخل موضوعات ${cat.title}...',
                      hintStyle: AppTheme.getCairoFont(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white54 : cat.primaryColor,
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkBg : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة الموضوعات المستقلة
            Expanded(
              child: filteredTopics.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد موضوعات مطابقة لبحثك',
                        style: AppTheme.getCairoFont(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTopics.length,
                      itemBuilder: (context, index) {
                        final topic = filteredTopics[index];
                        return _buildTopicCard(
                          context: context,
                          topic: topic,
                          number: index + 1,
                          cat: cat,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required BuildContext context,
    required InfoTopic topic,
    required int number,
    required InfoCategory cat,
    required bool isDark,
  }) {
    final hasImage = topic.imagePath != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : cat.primaryColor.withValues(alpha: 0.15),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoTopicDetailScreen(
                  topic: topic,
                  category: cat,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // الرقم أو الصورة المصغرة إن وجدت
                if (hasImage)
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cat.primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        topic.imagePath!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cat.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$number',
                      style: AppTheme.getCairoFont(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.goldAccent : cat.primaryColor,
                      ),
                    ),
                  ),

                const SizedBox(width: 14),

                // العنوان والوصف وشارات الصورة/الأدلة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: AppTheme.getCairoFont(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      if (topic.subtitle != null && topic.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          topic.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCairoFont(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (hasImage)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.image_rounded, size: 12, color: AppTheme.goldAccentDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    'رسم توضيحي',
                                    style: AppTheme.getCairoFont(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.goldAccent : AppTheme.goldAccentDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (topic.evidences.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cat.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${topic.evidences.length} دليل نبوي',
                                style: AppTheme.getCairoFont(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : cat.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
