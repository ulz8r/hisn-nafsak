import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_nafsak/data/athkar_data.dart';
import 'package:hisn_nafsak/data/sleep_wake_athkar_data.dart';
import 'package:hisn_nafsak/data/athkar_virtues_data.dart';
import 'package:hisn_nafsak/controllers/settings_controller.dart';
import 'package:hisn_nafsak/screens/sleep_wake_screen.dart';
import 'package:hisn_nafsak/screens/athkar_virtues_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('اختبارات أذكار النوم الصحيحة (Sleep Athkar Tests)', () {
    test('التحقق من عدد أذكار النوم وشمولها لكافة نصوص الصورة المعتمدة', () {
      final list = SleepWakeAthkarData.sleepAthkar;
      expect(list.length, equals(9), reason: 'يجب أن تحتوي أذكار النوم على ٩ أذكار صحيحة ومأثورة');

      // 1. النفث في الكفين بالمعوذات الثلاثة
      final muawwidhat = list.firstWhere((t) => t.id == 1);
      expect(muawwidhat.targetCount, equals(3));
      expect(muawwidhat.text.contains('قُلْ هُوَ اللَّهُ أَحَدٌ'), isTrue);
      expect(muawwidhat.text.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'), isTrue);
      expect(muawwidhat.text.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ'), isTrue);
      expect(muawwidhat.source, contains('البخاري'));

      // 2. آية الكرسي
      final ayatKursi = list.firstWhere((t) => t.id == 2);
      expect(ayatKursi.text.contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ'), isTrue);
      expect(ayatKursi.targetCount, equals(1));
      expect(ayatKursi.source, contains('البخاري'));

      // 3. آخر آيتين من سورة البقرة
      final baqarahLast2 = list.firstWhere((t) => t.id == 3);
      expect(baqarahLast2.text.contains('آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ'), isTrue);
      expect(baqarahLast2.source, contains('متفق عليه'));

      // 4. اللهم أسلمت وجهي إليك
      final aslamtu = list.firstWhere((t) => t.id == 4);
      expect(aslamtu.text.contains('اللَّهُمَّ أَسْلَمْتُ وَجْهِي إِلَيْكَ'), isTrue);
      expect(aslamtu.text.contains('وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ'), isTrue);
      expect(aslamtu.source, contains('متفق عليه'));

      // 5. باسمك رب وضعت جنبي
      final bismika = list.firstWhere((t) => t.id == 5);
      expect(bismika.text.contains('بِاسْمِكَ رَبِّ وَضَعْتُ جَنْبِي'), isTrue);
      expect(bismika.source, contains('متفق عليه'));

      // 6. التسبيح والتحميد والتكبير
      final tasbeeh = list.firstWhere((t) => t.id == 6);
      expect(tasbeeh.text.contains('سُبْحَانَ اللَّهِ (٣٣ مرة)'), isTrue);
      expect(tasbeeh.text.contains('وَالحَمْدُ لِلَّهِ (٣٣ مرة)'), isTrue);
      expect(tasbeeh.text.contains('وَاللَّهُ أَكْبَرُ (٣٤ مرة)'), isTrue);
      expect(tasbeeh.source, contains('متفق عليه'));

      // 7. الحمد لله الذي أطعمنا وسقانا
      final atamana = list.firstWhere((t) => t.id == 7);
      expect(atamana.text.contains('الحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا'), isTrue);
      expect(atamana.source, contains('مسلم'));

      // 8. اللهم خلقت نفسي وأنت توفاها
      final khalaqta = list.firstWhere((t) => t.id == 8);
      expect(khalaqta.text.contains('اللَّهُمَّ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا'), isTrue);
      expect(khalaqta.source, contains('مسلم'));

      // 9. اللهم رب السماوات ورب الأرض
      final rabbaSamawat = list.firstWhere((t) => t.id == 9);
      expect(rabbaSamawat.text.contains('اللَّهُمَّ رَبَّ السَّمَاوَاتِ وَرَبَّ الأَرْضِ وَرَبَّ العَرْشِ العَظِيمِ'), isTrue);
      expect(rabbaSamawat.text.contains('اقْضِ عَنَّا الدَّيْنَ ، وَأَغْنِنَا مِنَ الفَقْرِ'), isTrue);
      expect(rabbaSamawat.source, contains('مسلم'));
    });

    test('توافق AthkarData مع أذكار النوم والاستيقاظ', () {
      expect(AthkarData.sleepAthkar.length, equals(9));
      expect(AthkarData.wakeAthkar.length, equals(3));
    });
  });

  group('اختبارات أذكار الاستيقاظ (Wake Athkar Tests)', () {
    test('التحقق من صحة نصوص أذكار الاستيقاظ ومصادرها', () {
      final list = SleepWakeAthkarData.wakeAthkar;
      expect(list.length, equals(3));

      // 1. الحمد لله الذي أحيانا بعدما أماتنا
      expect(list[0].text, contains('الحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ'));
      expect(list[0].source, contains('البخاري'));

      // 2. الحمد لله الذي عافاني في جسدي
      expect(list[1].text, contains('الحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي'));
      expect(list[1].text, contains('وَرَدَّ عَلَيَّ رُوحِي ، وَأَذِنَ لِي بِذِكْرِهِ'));
      expect(list[1].source, contains('الترمذي'));

      // 3. لا إله إلا الله وحده لا شريك له ورب اغفر لي
      expect(list[2].text, contains('لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ'));
      expect(list[2].text, contains('رَبِّ اغْفِرْ لِي'));
      expect(list[2].source, contains('البخاري'));
    });
  });

  group('اختبارات فضائل الأذكار (Athkar Virtues Tests)', () {
    test('التحقق من النص الأول: فضل التسبيح والتحميد والتكبير قبل النوم', () {
      final text1 = AthkarVirtuesData.virtues.firstWhere((v) => v.id == 1);
      expect(text1.narrator, contains('عليّ بن أبي طالب'));
      expect(text1.hadithText, contains('فاطمة'));
      expect(text1.hadithText, contains('الرّحى'));
      expect(text1.hadithText, contains('فكبّرا الله أربعا وثلاثين'));
      expect(text1.source, contains('البخاري ومسلم'));
      expect(text1.additionalNarrations.length, greaterThanOrEqualTo(2));
      expect(text1.additionalNarrations.any((n) => n.contains('ليلة صِفِّين')), isTrue);
    });

    test('التحقق من النص الثاني: فضل الذكر عند الإيواء إلى الفراش', () {
      final text2 = AthkarVirtuesData.virtues.firstWhere((v) => v.id == 2);
      expect(text2.narrator, contains('أبو هريرة'));
      expect(text2.ruling, contains('صحيح'));
      expect(text2.hadithText, contains('زَبَدِ البَحْرِ'));
      expect(text2.hadithText, contains('لا إِلهَ إِلَّا اللهُ وَحْدَهُ لا شَرِيكَ لَهُ'));
    });
  });

  group('اختبارات الواجهات (UI Widget Tests)', () {
    testWidgets('شاشة أذكار النوم والاستيقاظ تعرض التبويبين والأذكار بشكل سليم', (tester) async {
      final settings = SettingsController();

      await tester.pumpWidget(
        MaterialApp(
          home: SleepWakeScreen(settingsController: settings),
        ),
      );

      expect(find.text('أذكار النوم والاستيقاظ'), findsOneWidget);
      expect(find.text('أذكار النوم (٩)'), findsOneWidget);
      expect(find.text('أذكار الاستيقاظ (٣)'), findsOneWidget);
      expect(find.text('ابدأ القراءة بالعداد التفاعلي'), findsOneWidget);
      expect(find.text('من أذكار النوم الصحيحة'), findsOneWidget);
    });

    testWidgets('شاشة فضائل الأذكار تعرض الأحاديث والتصنيفات والفضائل بدقة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AthkarVirtuesScreen(),
        ),
      );

      expect(find.text('فضائل الأذكار'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('فضل التسبيح والتحميد والتكبير قبل النوم'), findsOneWidget);
      expect(find.byIcon(Icons.format_quote_rounded), findsWidgets);
    });
  });
}
