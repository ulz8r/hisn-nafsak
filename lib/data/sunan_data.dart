import '../models/prayer_model.dart';

class SunanData {
  /// قائمة السنن الرواتب المؤكدة والسنن المستحبة
  static const List<SunnahItem> allSunan = [
    // سنة الفجر
    SunnahItem(
      id: 'fajr_before',
      prayerName: 'صلاة الفجر',
      title: 'سنة الفجر القبلية (ركعتان قبل الفجر)',
      rakahs: 2,
      isBefore: true,
      type: SunnahType.muakkadah,
      reward: '«رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا» [رواه مسلم]. وهي آكد السنن الرواتب.',
    ),

    // سنن الظهر
    SunnahItem(
      id: 'dhuhr_before',
      prayerName: 'صلاة الظهر',
      title: 'سنة الظهر القبلية (أربع ركعات بتسليمتين قبل الظهر)',
      rakahs: 4,
      isBefore: true,
      type: SunnahType.muakkadah,
      reward: '«أَنَّ النَّبِيَّ ﷺ كَانَ لَا يَدَعُ أَرْبَعًا قَبْلَ الظُّهْرِ» [رواه البخاري]. تُصلى ركعتين ثم ركعتين.',
    ),
    SunnahItem(
      id: 'dhuhr_after',
      prayerName: 'صلاة الظهر',
      title: 'سنة الظهر البعدية (ركعتان بعد الظهر)',
      rakahs: 2,
      isBefore: false,
      type: SunnahType.muakkadah,
      reward: 'من السنن الرواتب المؤكدة التي تكمّل أجر صلاة الظهر وتبني بيتاً في الجنة.',
    ),

    // سنة العصر (مستحبة غير مؤكدة)
    SunnahItem(
      id: 'asr_before',
      prayerName: 'صلاة العصر',
      title: 'سنة العصر القبلية (أربع ركعات قبل العصر - مستحبة)',
      rakahs: 4,
      isBefore: true,
      type: SunnahType.mustahabbah,
      reward: '«رَحِمَ اللَّهُ امْرَأً صَلَّى قَبْلَ الْعَصْرِ أَرْبَعًا» [رواه أبو داود والترمذي وحسنه]. وهي سنة مستحبة وليست من الرواتب المؤكدة الاثنتي عشرة.',
    ),

    // سنة المغرب
    SunnahItem(
      id: 'maghrib_after',
      prayerName: 'صلاة المغرب',
      title: 'سنة المغرب البعدية (ركعتان بعد المغرب)',
      rakahs: 2,
      isBefore: false,
      type: SunnahType.muakkadah,
      reward: 'من السنن الرواتب المؤكدة التي واظب عليها النبي ﷺ في الحضر.',
    ),

    // سنة العشاء
    SunnahItem(
      id: 'isha_after',
      prayerName: 'صلاة العشاء',
      title: 'سنة العشاء البعدية (ركعتان بعد العشاء)',
      rakahs: 2,
      isBefore: false,
      type: SunnahType.muakkadah,
      reward: 'من السنن الرواتب المؤكدة التي يختم بها المسلم صلوات يومه قبل الوتر.',
    ),
  ];

  /// عدد ركعات السنن الرواتب المؤكدة (12 ركعة)
  static const int totalMuakkadahRakahs = 12;

  /// فضل السنن الرواتب المؤكدة
  static const String muakkadahHadith =
      'قال رسول الله ﷺ: «مَا مِنْ عَبْدٍ مُسْلِمٍ يُصَلِّي لِلَّهِ كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا، غَيْرَ فَرِيضَةٍ، إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ» [رواه مسلم].';
}
