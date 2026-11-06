/// تصنيف الأذكار
enum TasbeehCategory {
  tasbeeh, // أذكار التسبيح
  tahmeed, // أذكار الحمد
  takbeer, // أذكار التكبير
  tahleel, // أذكار التهليل
  istighfar, // أذكار الاستغفار
  salawat, // الصلاة على النبي ﷺ
  other, // أذكار أخرى
}

/// نموذج الذكر في المسبحة المطورة
class TasbeehThikr {
  final String id;
  final String text;
  final TasbeehCategory category;
  final String categoryTitle;
  final int defaultTarget;
  final String? virtue;

  const TasbeehThikr({
    required this.id,
    required this.text,
    required this.category,
    required this.categoryTitle,
    this.defaultTarget = 100,
    this.virtue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'category': category.name,
        'categoryTitle': categoryTitle,
        'defaultTarget': defaultTarget,
        'virtue': virtue,
      };

  factory TasbeehThikr.fromJson(Map<String, dynamic> json) => TasbeehThikr(
        id: json['id'] as String,
        text: json['text'] as String,
        category: TasbeehCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => TasbeehCategory.other,
        ),
        categoryTitle: json['categoryTitle'] as String,
        defaultTarget: json['defaultTarget'] as int? ?? 100,
        virtue: json['virtue'] as String?,
      );
}

/// سجل أذكار اليوم
class DayTasbeehLog {
  final String dateString;
  final Map<String, int> counts; // thikrId -> count
  final Map<String, int> targets; // thikrId -> custom target

  DayTasbeehLog({
    required this.dateString,
    required this.counts,
    required this.targets,
  });

  int getCount(String id) => counts[id] ?? 0;
  int getTarget(String id, int defaultVal) => targets[id] ?? defaultVal;

  int get totalAllToday => counts.values.fold(0, (sum, count) => sum + count);

  Map<String, dynamic> toJson() => {
        'dateString': dateString,
        'counts': counts,
        'targets': targets,
      };

  factory DayTasbeehLog.fromJson(Map<String, dynamic> json) {
    final countsMap = <String, int>{};
    if (json['counts'] != null) {
      final c = json['counts'] as Map<String, dynamic>;
      c.forEach((k, v) => countsMap[k] = v as int);
    }

    final targetsMap = <String, int>{};
    if (json['targets'] != null) {
      final t = json['targets'] as Map<String, dynamic>;
      t.forEach((k, v) => targetsMap[k] = v as int);
    }

    return DayTasbeehLog(
      dateString: json['dateString'] as String,
      counts: countsMap,
      targets: targetsMap,
    );
  }
}
