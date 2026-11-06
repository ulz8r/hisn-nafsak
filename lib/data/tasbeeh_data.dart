import '../models/tasbeeh_model.dart';

class TasbeehData {
  /// جميع الأذكار المقسمة حسب التصنيفات الشرعية الدقيقة
  static const List<TasbeehThikr> thikrList = [
    // أذكار التسبيح
    TasbeehThikr(
      id: 'tasbeeh_1',
      text: 'سُبْحَانَ اللَّهِ',
      category: TasbeehCategory.tasbeeh,
      categoryTitle: 'أذكار التسبيح',
      defaultTarget: 100,
      virtue: '«أَيَعْجِزُ أَحَدُكُمْ أَنْ يَكْسِبَ كُلَّ يَوْمٍ أَلْفَ حَسَنَةٍ؟ يُسَبِّحُ مِائَةَ تَسْبِيحَةٍ، فَيُكْتَبُ لَهُ أَلْفُ حَسَنَةٍ» [رواه مسلم].',
    ),
    TasbeehThikr(
      id: 'tasbeeh_2',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      category: TasbeehCategory.tasbeeh,
      categoryTitle: 'أذكار التسبيح',
      defaultTarget: 100,
      virtue: '«مَنْ قَالَ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، فِي يَوْمٍ مِائَةَ مَرَّةٍ، حُطَّتْ خَطَايَاهُ، وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ» [متفق عليه].',
    ),
    TasbeehThikr(
      id: 'tasbeeh_3',
      text: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      category: TasbeehCategory.tasbeeh,
      categoryTitle: 'أذكار التسبيح',
      defaultTarget: 100,
      virtue: '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ» [متفق عليه].',
    ),
    TasbeehThikr(
      id: 'tasbeeh_4',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      category: TasbeehCategory.tasbeeh,
      categoryTitle: 'أذكار التسبيح',
      defaultTarget: 100,
      virtue: 'كلمتان خفيفتان على اللسان ثقيلتان في الميزان حبيبتان إلى الرحمن.',
    ),

    // أذكار الحمد
    TasbeehThikr(
      id: 'tahmeed_1',
      text: 'الْحَمْدُ لِلَّهِ',
      category: TasbeehCategory.tahmeed,
      categoryTitle: 'أذكار الحمد',
      defaultTarget: 100,
      virtue: '«وَالْحَمْدُ لِلَّهِ تَمْلَأُ الْمِيزَانَ» [رواه مسلم]. وهي أفضل الدعاء.',
    ),
    TasbeehThikr(
      id: 'tahmeed_2',
      text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      category: TasbeehCategory.tahmeed,
      categoryTitle: 'أذكار الحمد',
      defaultTarget: 100,
      virtue: 'فاتحة كتاب الله وثناؤه التام على ربوبيته ورحمته وإحسانه.',
    ),

    // أذكار التكبير
    TasbeehThikr(
      id: 'takbeer_1',
      text: 'اللَّهُ أَكْبَرُ',
      category: TasbeehCategory.takbeer,
      categoryTitle: 'أذكار التكبير',
      defaultTarget: 100,
      virtue: 'شعائر التوحيد وإعظام رب العالمين، ومن أحب الكلام إلى الله.',
    ),
    TasbeehThikr(
      id: 'takbeer_2',
      text: 'اللَّهُ أَكْبَرُ كَبِيرًا',
      category: TasbeehCategory.takbeer,
      categoryTitle: 'أذكار التكبير',
      defaultTarget: 100,
      virtue: '«عَجِبْتُ لَهَا، فُتِحَتْ لَهَا أَبْوَابُ السَّمَاءِ» [رواه مسلم].',
    ),

    // أذكار التهليل
    TasbeehThikr(
      id: 'tahleel_1',
      text: 'لَا إِلَهَ إِلَّا اللَّهُ',
      category: TasbeehCategory.tahleel,
      categoryTitle: 'أذكار التهليل',
      defaultTarget: 100,
      virtue: '«أَفْضَلُ الذِّكْرِ: لَا إِلَهَ إِلَّا اللَّهُ» [رواه الترمذي وحسنه].',
    ),
    TasbeehThikr(
      id: 'tahleel_2',
      text: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      category: TasbeehCategory.tahleel,
      categoryTitle: 'أذكار التهليل',
      defaultTarget: 100,
      virtue: '«كَانَتْ لَهُ عَدْلَ عَشْرِ رِقَابٍ، وَكُتِبَتْ لَهُ مِائَةُ حَسَنَةٍ، وَمُحِيَتْ عَنْهُ مِائَةُ سَيِّئَةٍ، وَكَانَتْ لَهُ حِرْزًا مِنَ الشَّيْطَانِ» [متفق عليه].',
    ),

    // أذكار الاستغفار
    TasbeehThikr(
      id: 'istighfar_1',
      text: 'أَسْتَغْفِرُ اللَّهَ',
      category: TasbeehCategory.istighfar,
      categoryTitle: 'أذكار الاستغفار',
      defaultTarget: 100,
      virtue: '«مَنْ لَزِمَ الِاسْتِغْفَارَ جَعَلَ اللَّهُ لَهُ مِنْ كُلِّ هَمٍّ فَرَجًا، وَمِنْ كُلِّ ضِيقٍ مَخْرَجًا، وَرَزَقَهُ مِنْ حَيْثُ لَا يَحْتَسِبُ».',
    ),
    TasbeehThikr(
      id: 'istighfar_2',
      text: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      category: TasbeehCategory.istighfar,
      categoryTitle: 'أذكار الاستغفار',
      defaultTarget: 100,
      virtue: '«وَاللَّهِ إِنِّي لَأَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ فِي الْيَوْمِ أَكْثَرَ مِنْ سَبْعِينَ مَرَّةً» [رواه البخاري].',
    ),
    TasbeehThikr(
      id: 'istighfar_3',
      text: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      category: TasbeehCategory.istighfar,
      categoryTitle: 'أذكار الاستغفار',
      defaultTarget: 100,
      virtue: 'كان يُعدّ للنبي ﷺ في المجلس الواحد مائة مرة قبل أن يقوم [رواه الترمذي وأبو داود].',
    ),

    // الصلاة على النبي ﷺ
    TasbeehThikr(
      id: 'salawat_1',
      text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      category: TasbeehCategory.salawat,
      categoryTitle: 'الصلاة على النبي ﷺ',
      defaultTarget: 100,
      virtue: '«مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا» [رواه مسلم]. وتُكفى همك ويُغفر ذنبك.',
    ),
    TasbeehThikr(
      id: 'salawat_2',
      text: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      category: TasbeehCategory.salawat,
      categoryTitle: 'الصلاة على النبي ﷺ',
      defaultTarget: 100,
      virtue: 'الصيغة الإبراهيمية العظيمة الموجبة للرحمة والبركة ورفعة الدرجات.',
    ),

    // أذكار أخرى
    TasbeehThikr(
      id: 'other_1',
      text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      category: TasbeehCategory.other,
      categoryTitle: 'أذكار أخرى',
      defaultTarget: 100,
      virtue: '«أَلَا أَدُلُّكَ عَلَى كَنْزٍ مِنْ كُنُوزِ الْجَنَّةِ؟ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ» [متفق عليه].',
    ),
    TasbeehThikr(
      id: 'other_2',
      text: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      category: TasbeehCategory.other,
      categoryTitle: 'أذكار أخرى',
      defaultTarget: 100,
      virtue: 'قالها إبراهيم عليه السلام حين أُلقي في النار، وقالها محمد ﷺ وأصحابه لما قيل لهم إن الناس قد جمعوا لكم [رواه البخاري].',
    ),
    TasbeehThikr(
      id: 'other_3',
      text: 'سُبْحَانَ اللَّهِ ، وَالْحَمْدُ لِلَّهِ ، وَلَا إِلَهَ إِلَّا اللَّهُ ، وَاللَّهُ أَكْبَرُ',
      category: TasbeehCategory.other,
      categoryTitle: 'أذكار أخرى',
      defaultTarget: 100,
      virtue: '«لَأَنْ أَقُولَ سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، أَحَبُّ إِلَيَّ مِمَّا طَلَعَتْ عَلَيْهِ الشَّمْسُ» [رواه مسلم].',
    ),
  ];

  static String getCategoryName(TasbeehCategory cat) {
    switch (cat) {
      case TasbeehCategory.tasbeeh:
        return 'التسبيح';
      case TasbeehCategory.tahmeed:
        return 'التحميد';
      case TasbeehCategory.takbeer:
        return 'التكبير';
      case TasbeehCategory.tahleel:
        return 'التهليل';
      case TasbeehCategory.istighfar:
        return 'الاستغفار';
      case TasbeehCategory.salawat:
        return 'الصلاة على النبي ﷺ';
      case TasbeehCategory.other:
        return 'أذكار مأثورة';
    }
  }
}
