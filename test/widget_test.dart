import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_nafsak/main.dart';
import 'package:hisn_nafsak/controllers/settings_controller.dart';
import 'package:hisn_nafsak/controllers/accountability_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads home screen properly with all sections including Quran, Athkar and Arbaeen', (WidgetTester tester) async {
    // Set a large screen size to view all sliver components
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final settingsController = SettingsController();
    final accountabilityController = AccountabilityController();

    await tester.pumpWidget(HisnNafsakApp(
      settingsController: settingsController,
      accountabilityController: accountabilityController,
    ));
    await tester.pumpAndSettle();

    // التحقق من عنوان التطبيق في الترويسة
    expect(find.text('حِصْنُ نَفْسِكَ'), findsWidgets);

    // التأكد من إزالة أيقونة المكتبة الإسلامية من الشريط العلوي
    expect(find.byTooltip('المكتبة الإسلامية'), findsNothing);

    // التحقق من وجود الأذكار الثلاثة في القائمة الرئيسية
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('أذكار المساء'), findsOneWidget);
    expect(find.text('أذكار بعد الصلاة'), findsOneWidget);

    // التحقق من وجود قسم القرآن الكريم ومحتوياته في القائمة الرئيسية
    expect(find.text('القرآن الكريم'), findsOneWidget);
    expect(find.text('جزء عمّ'), findsOneWidget);
    expect(find.text('جزء تبارك'), findsOneWidget);

    // التحقق من وجود الأربعون النووية في القائمة الرئيسية
    expect(find.text('الأربعون النووية'), findsOneWidget);

    // التحقق من وجود أقسام محاسبة النفس والأحاديث والمسبحة
    expect(find.text('محاسبة الصلوات والسنن'), findsOneWidget);
    expect(find.text('ماذا قدمت اليوم؟'), findsOneWidget);
    expect(find.text('وقفة مع نفسك – المراجعة اليومية'), findsOneWidget);
    expect(find.text('صحيح البخاري وحديث اليوم'), findsOneWidget);
    expect(find.text('المسبحة وعداد الأذكار'), findsOneWidget);
  });
}
