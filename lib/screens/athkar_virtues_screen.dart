import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/athkar_virtue_model.dart';
import '../data/athkar_virtues_data.dart';
import '../theme/app_theme.dart';

/// شاشة فضائل الأذكار النبوية الشريفة
class AthkarVirtuesScreen extends StatefulWidget {
  const AthkarVirtuesScreen({super.key});

  @override
  State<AthkarVirtuesScreen> createState() => _AthkarVirtuesScreenState();
}

class _AthkarVirtuesScreenState extends State<AthkarVirtuesScreen> {
  double _fontSizeDelta = 0.0;
  String _selectedCategory = 'الكل';

  void _copyToClipboard(BuildContext context, AthkarVirtue item) {
    final buffer = StringBuffer();
    buffer.writeln('【 ${item.title} 】');
    buffer.writeln(item.hadithText);
    buffer.writeln('• الراوي: ${item.narrator}');
    buffer.writeln('• المصدر: ${item.source}');
    buffer.writeln('• حكم المحدث: ${item.ruling}');
    buffer.writeln('• الفضل: ${item.virtueBenefit}');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ الحديث وفضله بنجاح',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allVirtues = AthkarVirtuesData.virtues;
    final categories = ['الكل', ...allVirtues.map((e) => e.category).toSet()];

    final filteredList = _selectedCategory == 'الكل'
        ? allVirtues
        : allVirtues.where((e) => e.category == _selectedCategory).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: Text(
            'فضائل الأذكار',
            style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.primaryGreen,
          foregroundColor: Colors.white,
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
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // لوحة الترويسة الذهبية
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2923), const Color(0xFF0F1A14)]
                      : [const Color(0xFF0D5C3A), const Color(0xFF1B8A5A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
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
                    child: const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بركات وكنوز الأذكار النبوية',
                          style: AppTheme.getCairoFont(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '﴿ وَالذَّاكِرِينَ اللَّهَ كَثِيرًا وَالذَّاكِرَاتِ أَعَدَّ اللَّهُ لَهُم مَّغْفِرَةً وَأَجْرًا عَظِيمًا ﴾',
                          style: AppTheme.getArabicFont(
                            fontSize: 13,
                            color: AppTheme.goldAccentLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // تصنيفات الفلترة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryGreen,
                      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                      labelStyle: AppTheme.getCairoFont(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : (isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // قائمة الأحاديث والفضائل
            ...filteredList.map((virtue) {
              return _buildVirtueCard(
                context: context,
                virtue: virtue,
                isDark: isDark,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtueCard({
    required BuildContext context,
    required AthkarVirtue virtue,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppTheme.primaryGreen.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وتصنيف الفضل وزر النسخ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          virtue.category,
                          style: AppTheme.getCairoFont(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.goldAccent : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        virtue.title,
                        style: AppTheme.getCairoFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  tooltip: 'نسخ الحديث وفضله',
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  onPressed: () => _copyToClipboard(context, virtue),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // صندوق نص الحديث الشريف مميز ومزخرف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF14241C)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote_rounded, color: AppTheme.goldAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'نص الحديث الشريف:',
                        style: AppTheme.getCairoFont(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.goldAccent : AppTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    virtue.hadithText,
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

            const SizedBox(height: 14),

            // بيانات الراوي والمصدر وحكم المحدث مفصولة وواضحة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildMetaRow(
                    icon: Icons.person_rounded,
                    label: 'الراوي:',
                    value: virtue.narrator,
                    valueColor: isDark ? Colors.white : Colors.black87,
                  ),
                  const Divider(height: 12),
                  _buildMetaRow(
                    icon: Icons.menu_book_rounded,
                    label: 'المصدر:',
                    value: virtue.source,
                    valueColor: isDark ? AppTheme.goldAccent : AppTheme.primaryGreenDark,
                  ),
                  const Divider(height: 12),
                  _buildMetaRow(
                    icon: Icons.verified_rounded,
                    label: 'خلاصة حكم المحدث:',
                    value: virtue.ruling,
                    valueColor: Colors.green.shade600,
                    isBadge: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // بيان فضل الذكر وثمرته
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.goldAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.stars_rounded, color: AppTheme.goldAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بيان فضل الذكر:',
                          style: AppTheme.getCairoFont(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.goldAccent : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          virtue.virtueBenefit,
                          style: AppTheme.getCairoFont(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // الروايات الأخرى إن وجدت
            if (virtue.additionalNarrations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...virtue.additionalNarrations.map((narration) {
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2832) : const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          narration,
                          style: AppTheme.getArabicFont(
                            fontSize: 14 + _fontSizeDelta,
                            height: 1.7,
                            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isBadge = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.getCairoFont(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isBadge
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: valueColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: valueColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      value,
                      style: AppTheme.getCairoFont(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                  ),
                )
              : Text(
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
