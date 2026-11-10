import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/info_models.dart';
import '../theme/app_theme.dart';

/// شاشة مستقلة لعرض تفاصيل ومعلومات وصور وأدلة موضوع واحد فقط
class InfoTopicDetailScreen extends StatefulWidget {
  final InfoTopic topic;
  final InfoCategory category;

  const InfoTopicDetailScreen({
    super.key,
    required this.topic,
    required this.category,
  });

  @override
  State<InfoTopicDetailScreen> createState() => _InfoTopicDetailScreenState();
}

class _InfoTopicDetailScreenState extends State<InfoTopicDetailScreen> {
  double _fontSizeDelta = 0.0;

  void _copyTopicText(BuildContext context) {
    final t = widget.topic;
    final buffer = StringBuffer();
    buffer.writeln('【 ${t.title} 】');
    if (t.rulingSummary != null && t.rulingSummary!.isNotEmpty) {
      buffer.writeln(t.rulingSummary);
      buffer.writeln();
    }
    if (t.question != null && t.question!.isNotEmpty) {
      buffer.writeln('السؤال:');
      buffer.writeln(t.question);
      buffer.writeln();
    }
    if (t.answerOrBody != null && t.answerOrBody!.isNotEmpty) {
      buffer.writeln(t.question != null ? 'الجواب:' : 'التفاصيل:');
      buffer.writeln(t.answerOrBody);
      buffer.writeln();
    }
    if (t.evidences.isNotEmpty) {
      buffer.writeln('الأدلة والأحاديث:');
      for (final e in t.evidences) {
        buffer.writeln('• ${e.hadithText}');
        if (e.narrator != null) buffer.writeln('  الراوي: ${e.narrator}');
        if (e.source != null) buffer.writeln('  المصدر: ${e.source}');
        if (e.ruling != null) buffer.writeln('  الحكم: ${e.ruling}');
      }
    }
    if (t.footerNote != null) {
      buffer.writeln(t.footerNote);
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ محتوى الموضوع بالكامل',
              style: AppTheme.getCairoFont(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.getCairoFont(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.black54),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'يمكنك التكبير والتصغير بإصبعين',
                    style: AppTheme.getCairoFont(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = widget.topic;
    final catColor = widget.category.primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAF9),
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkCard : catColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.category.title,
            style: AppTheme.getCairoFont(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actions: [
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
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'نسخ الموضوع',
              onPressed: () => _copyTopicText(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. عنوان الموضوع
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.category.gradientColors,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: catColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.category.title,
                        style: AppTheme.getCairoFont(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.title,
                      style: AppTheme.getCairoFont(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    if (t.subtitle != null && t.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        t.subtitle!,
                        style: AppTheme.getCairoFont(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. الصورة أو الرسم التوضيحي الخاص بالموضوع (إن وجد)
              if (t.imagePath != null) ...[
                GestureDetector(
                  onTap: () => _showZoomableImage(context, t.imagePath!, t.title),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: catColor.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            t.imagePath!,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (t.imageCaption != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t.imageCaption!,
                              textAlign: TextAlign.center,
                              style: AppTheme.getCairoFont(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.zoom_in_rounded, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              'اضغط على الصورة للتكبير',
                              style: AppTheme.getCairoFont(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // التمهيد / الحكم الملخص (إن وجد في محظورات الصلاة والمسجد)
              if (t.rulingSummary != null && t.rulingSummary!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: catColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          t.rulingSummary!,
                          style: AppTheme.getCairoFont(
                            fontSize: 14 + _fontSizeDelta,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : catColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. السؤال (إن وجد)
              if (t.question != null && t.question!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.goldAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, color: AppTheme.goldAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'السؤال:',
                            style: AppTheme.getCairoFont(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.goldAccent : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        t.question!,
                        style: AppTheme.getArabicFont(
                          fontSize: 17 + _fontSizeDelta,
                          height: 1.75,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3 (تابع). نص المعلومات أو الجواب
              if (t.answerOrBody != null && t.answerOrBody!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : catColor.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            t.question != null ? Icons.question_answer_rounded : Icons.article_rounded,
                            color: catColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.question != null ? 'الجواب:' : 'التفاصيل والشرح:',
                            style: AppTheme.getCairoFont(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.goldAccent : catColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        t.answerOrBody!,
                        style: AppTheme.getArabicFont(
                          fontSize: 18 + _fontSizeDelta,
                          height: 1.85,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 4 و 5. الأحاديث والأدلة والرواة والمصادر
              if (t.evidences.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: catColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'الأحاديث والأدلة والمصادر',
                      style: AppTheme.getCairoFont(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...t.evidences.map((ev) => _buildEvidenceCard(ev, isDark, catColor)),
              ],

              // ملاحظة ختامية إن وجدت
              if (t.footerNote != null && t.footerNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.footerNote!,
                    style: AppTheme.getCairoFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(InfoEvidence ev, bool isDark, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: AppTheme.goldAccent, size: 20),
              const SizedBox(width: 6),
              if (ev.hadithNumber != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'رقم: ${ev.hadithNumber}',
                    style: AppTheme.getCairoFont(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.goldAccent : const Color(0xFF92400E),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            ev.hadithText,
            style: AppTheme.getArabicFont(
              fontSize: 18 + _fontSizeDelta,
              height: 1.85,
              color: isDark ? Colors.white : const Color(0xFF064E3B),
            ),
            textAlign: TextAlign.justify,
          ),
          if (ev.narrator != null || ev.source != null || ev.ruling != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  if (ev.narrator != null)
                    _buildMetaLine(
                      icon: Icons.person_rounded,
                      label: 'الراوي:',
                      value: ev.narrator!,
                      isDark: isDark,
                      valueColor: isDark ? Colors.white : Colors.black87,
                    ),
                  if (ev.narrator != null && (ev.source != null || ev.ruling != null))
                    const Divider(height: 10),
                  if (ev.source != null)
                    _buildMetaLine(
                      icon: Icons.bookmark_rounded,
                      label: 'المصدر:',
                      value: ev.source!,
                      isDark: isDark,
                      valueColor: isDark ? AppTheme.goldAccent : accentColor,
                    ),
                  if (ev.source != null && ev.ruling != null) const Divider(height: 10),
                  if (ev.ruling != null)
                    _buildMetaLine(
                      icon: Icons.verified_rounded,
                      label: 'الحكم:',
                      value: ev.ruling!,
                      isDark: isDark,
                      valueColor: Colors.green.shade600,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaLine({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.getCairoFont(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTheme.getCairoFont(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
