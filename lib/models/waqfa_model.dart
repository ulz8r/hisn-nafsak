/// نموذج جلسة وقفة مع نفسك والمراجعة اليومية
class WaqfaRecord {
  final String dateString; // YYYY-MM-DD
  final String proudOf; // أكثر شيء أفتخر بإنجازه اليوم
  final String shortfall; // تقصيري اليوم
  final String fixTomorrow; // ما الذي أريد إصلاحه غداً؟
  final String duaaOrIntention; // دعاء أو نية أريد أن أبدأ بها يومي القادم
  final Map<String, String> answers; // إجابات أسئلة محاسبة النفس
  final List<String> tomorrowGoals; // خطة الغد وأهدافه
  final DateTime createdAt;

  WaqfaRecord({
    required this.dateString,
    this.proudOf = '',
    this.shortfall = '',
    this.fixTomorrow = '',
    this.duaaOrIntention = '',
    Map<String, String>? answers,
    List<String>? tomorrowGoals,
    DateTime? createdAt,
  })  : answers = answers ?? {},
        tomorrowGoals = tomorrowGoals ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'dateString': dateString,
        'proudOf': proudOf,
        'shortfall': shortfall,
        'fixTomorrow': fixTomorrow,
        'duaaOrIntention': duaaOrIntention,
        'answers': answers,
        'tomorrowGoals': tomorrowGoals,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WaqfaRecord.fromJson(Map<String, dynamic> json) {
    final ans = <String, String>{};
    if (json['answers'] != null) {
      final a = json['answers'] as Map<String, dynamic>;
      a.forEach((k, v) => ans[k] = v.toString());
    }

    final goals = <String>[];
    if (json['tomorrowGoals'] != null) {
      for (final g in json['tomorrowGoals'] as List<dynamic>) {
        goals.add(g.toString());
      }
    }

    return WaqfaRecord(
      dateString: json['dateString'] as String,
      proudOf: json['proudOf'] as String? ?? '',
      shortfall: json['shortfall'] as String? ?? '',
      fixTomorrow: json['fixTomorrow'] as String? ?? '',
      duaaOrIntention: json['duaaOrIntention'] as String? ?? '',
      answers: ans,
      tomorrowGoals: goals,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
