import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../theme/app_theme.dart';
import 'info_prayer_data.dart';
import 'info_prohibitions_data.dart';

/// المرجع الموحد لتصنيفات قسم «معلومات»
class InfoData {
  static const List<InfoCategory> categories = [
    InfoCategory(
      id: 'prayer_info',
      title: 'معلومات عن الصلاة',
      subtitle: 'أحكام وآداب وفتاوى وأحاديث متكاملة حول الصلاة والجنازة',
      badge: '١٧ موضوعاً',
      icon: Icons.mosque_rounded,
      primaryColor: AppTheme.primaryGreen,
      gradientColors: [Color(0xFF064E3B), Color(0xFF047857)],
      topics: InfoPrayerData.topics,
    ),
    InfoCategory(
      id: 'prayer_prohibitions',
      title: 'محظورات الصلاة',
      subtitle: 'أخطاء ومحظورات منهي عنها أثناء الصلاة مع الرسومات التوضيحية والأدلة',
      badge: '٤ موضوعات مصورة',
      icon: Icons.warning_amber_rounded,
      primaryColor: Color(0xFFB45309),
      gradientColors: [Color(0xFF92400E), Color(0xFFD97706)],
      topics: InfoProhibitionsData.prayerProhibitions,
    ),
    InfoCategory(
      id: 'mosque_prohibitions',
      title: 'محظورات المسجد',
      subtitle: 'تنبيهات نبوية وآداب واجبة لحرمة المسجد وعدم إيذاء المصلين والملائكة',
      badge: 'موضوعان مصوران',
      icon: Icons.campaign_rounded,
      primaryColor: Color(0xFF991B1B),
      gradientColors: [Color(0xFF7F1D1D), Color(0xFFDC2626)],
      topics: InfoProhibitionsData.mosqueProhibitions,
    ),
  ];
}
