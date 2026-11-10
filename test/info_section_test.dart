import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_nafsak/data/info_data.dart';
import 'package:hisn_nafsak/data/info_prayer_data.dart';
import 'package:hisn_nafsak/data/info_prohibitions_data.dart';
import 'package:hisn_nafsak/screens/info_home_screen.dart';
import 'package:hisn_nafsak/screens/info_category_topics_screen.dart';
import 'package:hisn_nafsak/screens/info_topic_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('اختبارات هيكل وبيانات قسم معلومات (Info Section Data Tests)', () {
    test('التحقق من التصنيفات الثلاثة المستقلة في قسم معلومات', () {
      expect(InfoData.categories.length, equals(3));
      expect(InfoData.categories[0].title, equals('معلومات عن الصلاة'));
      expect(InfoData.categories[1].title, equals('محظورات الصلاة'));
      expect(InfoData.categories[2].title, equals('محظورات المسجد'));
    });

    test('التصنيف الأول: معلومات عن الصلاة يحتوي على 17 موضوعاً دون تكرار صلاة الضحى', () {
      const topics = InfoPrayerData.topics;
      expect(topics.length, equals(17));

      // التأكد من عدم تكرار صلاة الضحى
      final duhaCount = topics.where((t) => t.title.contains('الضحى')).length;
      expect(duhaCount, equals(1), reason: 'يجب عرض موضوع صلاة الضحى مرة واحدة فقط');

      // التأكد من وجود كافة الموضوعات السبعة عشر
      final expectedTitles = [
        'كيف تؤدى صلاة الضحى؟',
        'كيفية صلاة الاستخارة ودعاؤها ووقتها',
        'الصلاة مع مدافعة الريح',
        'اتخاذ مكان واحد للصلاة في المسجد',
        'إغماض العينين في الصلاة',
        'التلثم في الصلاة والاستناد إلى ركن (الاتكاء)',
        'كثرة الحركة في الصلاة',
        'كراهة وضع اليد على الخاصرة في الصلاة',
        'الصلاة بحضرة الطعام ومدافعة الأخبثين',
        'النهي عن رفع البصر إلى السماء في الصلاة',
        'الإشارة في الصلاة لرد السلام أو حاجة تعرض',
        'كراهة الالتفات في الصلاة إلا من حاجة',
        'ما يقطع الصلاة بمروره',
        'نواقض الصلاة من ريح أو رعاف',
        'رعاف الأنف أثناء الصلاة',
        'صلاة القيام وعدد ركعاتها',
        'الجنازة واتباعها',
      ];
      for (final title in expectedTitles) {
        expect(topics.any((t) => t.title == title), isTrue, reason: 'الموضوع مفقود: $title');
      }
    });

    test('التصنيف الثاني: محظورات الصلاة يحتوي على 4 مواضيع مصورة بصور مستقلة', () {
      const topics = InfoProhibitionsData.prayerProhibitions;
      expect(topics.length, equals(4));

      final imagePaths = topics.map((t) => t.imagePath).toList();
      expect(imagePaths.every((p) => p != null && p.contains('prayer_prohibitions/')), isTrue);
      expect(imagePaths.toSet().length, equals(4), reason: 'لا يجوز تكرار صورة بين موضوعين');

      for (final path in imagePaths) {
        expect(File(path!).existsSync(), isTrue, reason: 'ملف الصورة غير موجود: $path');
      }
    });

    test('التصنيف الثالث: محظورات المسجد يحتوي على موضوعين مصورين بصور مستقلة', () {
      const topics = InfoProhibitionsData.mosqueProhibitions;
      expect(topics.length, equals(2));

      final imagePaths = topics.map((t) => t.imagePath).toList();
      expect(imagePaths.every((p) => p != null && p.contains('mosque_prohibitions/')), isTrue);
      expect(imagePaths.toSet().length, equals(2), reason: 'لا يجوز تكرار صورة بين موضوعين');

      for (final path in imagePaths) {
        expect(File(path!).existsSync(), isTrue, reason: 'ملف الصورة غير موجود: $path');
      }
    });

    test('التأكد من خلو النصوص من الرموز المجهولة (PUA U+F074)', () {
      for (final cat in InfoData.categories) {
        for (final t in cat.topics) {
          expect(t.title.contains('\uf074'), isFalse);
          expect(t.question?.contains('\uf074') ?? false, isFalse);
          expect(t.answerOrBody?.contains('\uf074') ?? false, isFalse);
          for (final e in t.evidences) {
            expect(e.hadithText.contains('\uf074'), isFalse);
          }
        }
      }
    });
  });

  group('اختبارات الواجهات والتنقل لقسم معلومات (Info UI & Navigation Tests)', () {
    testWidgets('فتح الشاشة الرئيسية لقسم معلومات ثم التصنيف ثم صفحة الموضوع المستقلة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InfoHomeScreen(),
        ),
      );

      // التحقق من وجود التصنيفات الثلاثة
      expect(find.text('معلومات دينية'), findsOneWidget);
      expect(find.text('معلومات عن الصلاة'), findsOneWidget);
      expect(find.text('محظورات الصلاة'), findsOneWidget);
      expect(find.text('محظورات المسجد'), findsOneWidget);

      // الضغط على تصنيف محظورات الصلاة
      await tester.tap(find.text('محظورات الصلاة'));
      await tester.pumpAndSettle();

      // التحقق من شاشة الموضوعات المستقلة
      expect(find.byType(InfoCategoryTopicsScreen), findsOneWidget);
      expect(find.text('رفع الأكمام في الصلاة'), findsOneWidget);
      expect(find.text('تغطية الوجه في الصلاة'), findsOneWidget);
      expect(find.text('إسبال الثوب في الصلاة أو خارجها'), findsOneWidget);
      expect(find.text('رفع البصر إلى السماء في الصلاة'), findsOneWidget);

      // الضغط على موضوع رفع الأكمام
      await tester.tap(find.text('رفع الأكمام في الصلاة'));
      await tester.pumpAndSettle();

      // التحقق من شاشة تفاصيل الموضوع المستقلة وظهور الصورة والحديث
      expect(find.byType(InfoTopicDetailScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.textContaining('أُمرتُ أن أسجدَ على سبعةٍ'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // اختبار زر الرجوع
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(InfoCategoryTopicsScreen), findsOneWidget);
    });

    testWidgets('التحقق من عرض جميع مواضيع محظورات المسجد ومعلومات عن الصلاة', (tester) async {
      final mosqueCat = InfoData.categories[2];
      await tester.pumpWidget(
        MaterialApp(
          home: InfoCategoryTopicsScreen(category: mosqueCat),
        ),
      );

      expect(find.text('إيذاء المصلين بالروائح الكريهة أو الدخان'), findsOneWidget);
      expect(find.text('رفع الصوت في الصلاة وإزعاج المصلين'), findsOneWidget);

      await tester.tap(find.text('رفع الصوت في الصلاة وإزعاج المصلين'));
      await tester.pumpAndSettle();

      expect(find.byType(InfoTopicDetailScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.textContaining('كلكم مناج ربه'), findsOneWidget);
    });
  });
}
