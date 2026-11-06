import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_nafsak/models/prayer_model.dart';
import 'package:hisn_nafsak/models/deeds_model.dart';
import 'package:hisn_nafsak/controllers/accountability_controller.dart';
import 'package:hisn_nafsak/data/sunan_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('محاسبة الصلوات والسنن (Prayer Accountability Tests)', () {
    test('القاعدة الشرعية: لا يمكن احتساب الصلاة جماعة إذا لم يتم أداء الصلاة نفسها', () {
      final item = const PrayerItem(id: 'fajr', name: 'الفجر', prayed: false, inJamaah: false);
      // محاولة جعلها جماعة والصلاة غير مؤداة
      final modified = item.copyWith(prayed: false, inJamaah: true);
      expect(modified.prayed, false);
      expect(modified.inJamaah, false);
    });

    test('إلغاء أداء الصلاة يلغي صفة الجماعة تلقائياً', () {
      final item = const PrayerItem(id: 'dhuhr', name: 'الظهر', prayed: true, inJamaah: true);
      final unprayed = item.copyWith(prayed: false);
      expect(unprayed.prayed, false);
      expect(unprayed.inJamaah, false);
    });

    test('حساب الصلوات ونسبة الإنجاز بدقة', () {
      final prayers = {
        'fajr': const PrayerItem(id: 'fajr', name: 'الفجر', prayed: true, inJamaah: true),
        'dhuhr': const PrayerItem(id: 'dhuhr', name: 'الظهر', prayed: true, inJamaah: false),
        'asr': const PrayerItem(id: 'asr', name: 'العصر', prayed: true, inJamaah: true),
        'maghrib': const PrayerItem(id: 'maghrib', name: 'المغرب', prayed: false, inJamaah: false),
        'isha': const PrayerItem(id: 'isha', name: 'العشاء', prayed: false, inJamaah: false),
      };

      final log = DayPrayerLog(
        dateString: '2026-11-04',
        prayers: prayers,
        sunanStatus: {},
      );

      expect(log.totalPrayedCount, 3);
      expect(log.jamaahCount, 2);
      expect(log.prayerPercentage, 0.6);
    });

    test('التمييز بين السنن الرواتب المؤكدة والسنن المستحبة', () {
      final muakkadah = SunanData.allSunan.where((s) => s.type == SunnahType.muakkadah);
      final mustahabbah = SunanData.allSunan.where((s) => s.type == SunnahType.mustahabbah);

      expect(muakkadah.length, 5); // فجر، قبل الظهر، بعد الظهر، بعد المغرب، بعد العشاء
      expect(SunanData.totalMuakkadahRakahs, 12);
      expect(mustahabbah.length, 1); // 4 ركعات قبل العصر
      expect(mustahabbah.first.id, 'asr_before');
    });
  });

  group('محاسبة الأعمال اليومية (Daily Deeds Tests)', () {
    test('حساب عدد ونسبة الأعمال المنجزة', () {
      final deeds = [
        const DeedItem(id: 1, title: 'صلوات', isCompleted: true),
        const DeedItem(id: 2, title: 'قرآن', isCompleted: true),
        const DeedItem(id: 3, title: 'أذكار الصباح', isCompleted: false),
        const DeedItem(id: 4, title: 'صدقة', isCompleted: false),
      ];

      final log = DayDeedsLog(dateString: '2026-11-04', deeds: deeds);

      expect(log.completedCount, 2);
      expect(log.totalCount, 4);
      expect(log.completionRate, 0.5);
      expect(log.completedDeeds.length, 2);
      expect(log.missedDeeds.length, 2);
    });
  });

  group('المسبحة وعداد الأذكار (Tasbeeh Tests)', () {
    test('تحديد الهدف والزيادة والتصفير', () async {
      final controller = AccountabilityController();
      await controller.loadDataForDate(DateTime.now());

      await controller.setTasbeehTarget('tasbeeh_1', 100);
      expect(controller.currentTasbeehLog?.getTarget('tasbeeh_1', 33), 100);

      await controller.incrementTasbeeh('tasbeeh_1', delta: 5);
      expect(controller.currentTasbeehLog?.getCount('tasbeeh_1'), 5);

      await controller.resetTasbeehCounter('tasbeeh_1');
      expect(controller.currentTasbeehLog?.getCount('tasbeeh_1'), 0);
    });
  });
}
