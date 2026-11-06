/// نموذج صلاة الفريضة
class PrayerItem {
  final String id;
  final String name;
  final bool prayed;
  final bool inJamaah;

  const PrayerItem({
    required this.id,
    required this.name,
    this.prayed = false,
    this.inJamaah = false,
  });

  PrayerItem copyWith({
    bool? prayed,
    bool? inJamaah,
  }) {
    // قاعدة شرعية وبرمجية: لا تصح الجماعة إذا لم تُؤدَّ الصلاة أصلاً
    final newPrayed = prayed ?? this.prayed;
    final newJamaah = newPrayed ? (inJamaah ?? this.inJamaah) : false;

    return PrayerItem(
      id: id,
      name: name,
      prayed: newPrayed,
      inJamaah: newJamaah,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'prayed': prayed,
        'inJamaah': inJamaah,
      };

  factory PrayerItem.fromJson(Map<String, dynamic> json) => PrayerItem(
        id: json['id'] as String,
        name: json['name'] as String,
        prayed: json['prayed'] as bool? ?? false,
        inJamaah: json['inJamaah'] as bool? ?? false,
      );
}

/// تصنيف السنن
enum SunnahType {
  muakkadah, // سنة راتبة مؤكدة
  mustahabbah, // سنة مستحبة غير مؤكدة
}

/// نموذج السنة الراتبة أو المستحبة
class SunnahItem {
  final String id;
  final String prayerName; // الصلاة التابعة لها (الفجر، الظهر...)
  final String title; // مثلاً: ركعتان قبل الفجر
  final int rakahs; // عدد الركعات
  final bool isBefore; // قبلية أم بعدية
  final SunnahType type; // مؤكدة أم مستحبة
  final String reward; // الفضل الشرعي
  final bool isCompleted;

  const SunnahItem({
    required this.id,
    required this.prayerName,
    required this.title,
    required this.rakahs,
    required this.isBefore,
    required this.type,
    required this.reward,
    this.isCompleted = false,
  });

  SunnahItem copyWith({bool? isCompleted}) {
    return SunnahItem(
      id: id,
      prayerName: prayerName,
      title: title,
      rakahs: rakahs,
      isBefore: isBefore,
      type: type,
      reward: reward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isCompleted': isCompleted,
      };
}

/// سجل اليوم الكامل للصلوات والسنن
class DayPrayerLog {
  final String dateString; // YYYY-MM-DD
  final Map<String, PrayerItem> prayers;
  final Map<String, bool> sunanStatus; // id -> isCompleted

  DayPrayerLog({
    required this.dateString,
    required this.prayers,
    required this.sunanStatus,
  });

  int get totalPrayedCount => prayers.values.where((p) => p.prayed).length;
  int get jamaahCount => prayers.values.where((p) => p.inJamaah).length;
  double get prayerPercentage => prayers.isEmpty ? 0.0 : (totalPrayedCount / prayers.length);

  Map<String, dynamic> toJson() => {
        'dateString': dateString,
        'prayers': prayers.map((k, v) => MapEntry(k, v.toJson())),
        'sunanStatus': sunanStatus,
      };

  factory DayPrayerLog.fromJson(Map<String, dynamic> json) {
    final prayersMap = <String, PrayerItem>{};
    if (json['prayers'] != null) {
      final p = json['prayers'] as Map<String, dynamic>;
      p.forEach((k, v) {
        prayersMap[k] = PrayerItem.fromJson(v as Map<String, dynamic>);
      });
    }

    final sunanMap = <String, bool>{};
    if (json['sunanStatus'] != null) {
      final s = json['sunanStatus'] as Map<String, dynamic>;
      s.forEach((k, v) {
        sunanMap[k] = v as bool;
      });
    }

    return DayPrayerLog(
      dateString: json['dateString'] as String,
      prayers: prayersMap,
      sunanStatus: sunanMap,
    );
  }
}
