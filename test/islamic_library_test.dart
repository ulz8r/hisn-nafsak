import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisn_nafsak/data/post_prayer_athkar_data.dart';
import 'package:hisn_nafsak/data/athkar_data.dart';
import 'package:hisn_nafsak/services/storage_service.dart';
import 'package:hisn_nafsak/controllers/settings_controller.dart';
import 'package:hisn_nafsak/screens/islamic_library_screen.dart';
import 'package:hisn_nafsak/screens/document_reader_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('اختبارات أذكار بعد الصلاة (Post Prayer Athkar Data Tests)', () {
    test('التحقق من اكتمال عناصر أذكار بعد الصلاة المفروضة وصحتها', () {
      final list = PostPrayerAthkarData.postPrayerAthkar;
      expect(list.length, 14);

      // الذكر الأول: الاستغفار ٣ مرات
      expect(list[0].text, contains('أَسْتَغْفِرُ اللهَ'));
      expect(list[0].targetCount, 3);

      // الذكر الثاني: اللهم أنت السلام
      expect(list[1].text, contains('اللَّهُمَّ أَنْتَ السَّلَامُ'));
      expect(list[1].targetCount, 1);

      // الذكر الثالث: التهليل بعد الفجر والمغرب (١٠ مرات)
      expect(list[2].text, contains('يُحْيِي وَيُمِيتُ'));
      expect(list[2].targetCount, 10);

      // الذكر الرابع: مخلصين له الدين
      expect(list[3].text, contains('مُخْلِصِينَ لَهُ الدِّينَ'));
      expect(list[3].targetCount, 1);

      // الذكر الخامس: اللهم لا مانع لما أعطيت
      expect(list[4].text, contains('اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ'));
      expect(list[4].targetCount, 1);

      // التسبيح، التحميد، التكبير (٣٣ مرة لكل منها)
      expect(list[5].text, contains('سُبْحَانَ اللهِ'));
      expect(list[5].targetCount, 33);

      expect(list[6].text, contains('الحَمْدُ للهِ'));
      expect(list[6].targetCount, 33);

      expect(list[7].text, contains('اللهُ أَكْبَرُ'));
      expect(list[7].targetCount, 33);

      // تمام المائة
      expect(list[8].text, contains('لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ'));
      expect(list[8].targetCount, 1);

      // تهليل عبد الله بن الزبير
      expect(list[9].text, contains('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ'));
      expect(list[9].targetCount, 1);

      // آية الكرسي
      expect(list[10].text, contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ'));
      expect(list[10].targetCount, 1);

      // سورة الإخلاص
      expect(list[11].text, contains('قُلْ هُوَ اللَّهُ أَحَدٌ'));
      expect(list[11].targetCount, 3);

      // سورة الفلق
      expect(list[12].text, contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'));
      expect(list[12].targetCount, 3);

      // سورة الناس
      expect(list[13].text, contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ'));
      expect(list[13].targetCount, 3);
    });

    test('توافق AthkarData مع PostPrayerAthkarData', () {
      expect(AthkarData.postPrayerAthkar.length, 14);
      expect(AthkarData.postPrayerAthkar[0].text, equals(PostPrayerAthkarData.postPrayerAthkar[0].text));
    });
  });

  group('اختبارات حفظ تقدم القراءة في المكتبة الإسلامية (Storage Tracking Tests)', () {
    test('حفظ واسترجاع موضع آخر صفحة/ذكر بدقة', () async {
      final storage = StorageService.instance;

      // القيمة الافتراضية
      final initAmma = await storage.getLibraryLastPosition('juz_amma');
      expect(initAmma, 1);

      // حفظ موضع جديد
      await storage.saveLibraryLastPosition('juz_amma', 15);
      final updatedAmma = await storage.getLibraryLastPosition('juz_amma');
      expect(updatedAmma, 15);

      // تتبع الأربعين النووية
      await storage.saveLibraryLastPosition('arbaeen', 28);
      final arbaeenPage = await storage.getLibraryLastPosition('arbaeen');
      expect(arbaeenPage, 28);

      // تتبع أذكار بعد الصلاة
      await storage.saveLibraryLastPosition('post_prayer', 9);
      final postPrayerThikr = await storage.getLibraryLastPosition('post_prayer');
      expect(postPrayerThikr, 9);
    });
  });

  group('اختبارات واجهة المكتبة الإسلامية (Islamic Library UI Tests)', () {
    testWidgets('عرض بطاقات الأقسام الستة في المكتبة الإسلامية', (tester) async {
      final settings = SettingsController();

      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: IslamicLibraryScreen(settingsController: settings),
        ),
      );
      await tester.pumpAndSettle();

      // التحقق من وجود العنوان
      expect(find.text('المكتبة الإسلامية'), findsOneWidget);

      // التحقق من وجود الأقسام الستة كاملة
      expect(find.text('أذكار الصباح'), findsOneWidget);
      expect(find.text('أذكار المساء'), findsOneWidget);
      expect(find.text('أذكار بعد الصلاة'), findsOneWidget);
      expect(find.text('جزء عمّ (الجزء الثلاثون)'), findsOneWidget);
      expect(find.text('جزء تبارك (الجزء التاسع والعشرون)'), findsOneWidget);
      expect(find.text('الأربعون النووية'), findsOneWidget);
    });

    testWidgets('شاشة عرض الوثيقة (DocumentReaderScreen) تعمل وتظهر رقم الصفحة والمصحف', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: DocumentReaderScreen(
            title: 'جزء عمّ (القرآن الكريم)',
            sectionKey: 'juz_amma',
            assetFolder: 'juz_amma',
            totalPages: 23,
            initialPage: 5,
            mushafStartPage: 582,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('جزء عمّ (القرآن الكريم)'), findsOneWidget);
      expect(find.text('صفحة 5 من 23'), findsOneWidget);
      expect(find.text('المصحف: صفحة 586'), findsOneWidget); // 582 + 5 - 1 = 586
    });
  });
}
