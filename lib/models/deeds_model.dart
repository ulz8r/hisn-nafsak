/// نموذج العمل اليومي (المعياري أو المضاف من المستخدم)
class DeedItem {
  final int id;
  final String title;
  final bool isCompleted;
  final bool isCustom;

  const DeedItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isCustom = false,
  });

  DeedItem copyWith({
    bool? isCompleted,
    String? title,
  }) {
    return DeedItem(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'isCustom': isCustom,
      };

  factory DeedItem.fromJson(Map<String, dynamic> json) => DeedItem(
        id: json['id'] as int,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        isCustom: json['isCustom'] as bool? ?? false,
      );
}

/// سجل اليوم للأعمال الصالحة والملاحظات
class DayDeedsLog {
  final String dateString;
  final List<DeedItem> deeds;
  final String notes;

  DayDeedsLog({
    required this.dateString,
    required this.deeds,
    this.notes = '',
  });

  int get completedCount => deeds.where((d) => d.isCompleted).length;
  int get totalCount => deeds.length;
  double get completionRate => totalCount == 0 ? 0.0 : (completedCount / totalCount);

  List<DeedItem> get completedDeeds => deeds.where((d) => d.isCompleted).toList();
  List<DeedItem> get missedDeeds => deeds.where((d) => !d.isCompleted).toList();

  Map<String, dynamic> toJson() => {
        'dateString': dateString,
        'deeds': deeds.map((d) => d.toJson()).toList(),
        'notes': notes,
      };

  factory DayDeedsLog.fromJson(Map<String, dynamic> json) {
    return DayDeedsLog(
      dateString: json['dateString'] as String,
      deeds: (json['deeds'] as List<dynamic>?)
              ?.map((d) => DeedItem.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }
}
