/// نموذج الحديث النبوي الشريف من صحيح البخاري
class HadithItem {
  final int id;
  final String text; // نص الحديث الشريف
  final String narrator; // الراوي (عن عمر بن الخطاب، عن أبي هريرة...)
  final String source; // المصدر (صحيح البخاري - كتاب الإيمان / رقم الحديث)
  final String chapter; // الباب أو الموضوع
  final String explanation; // الشرح والفوائد المستفادة
  final String category; // التصنيف (الإيمان، الصلاة، الأخلاق، الذكر...)
  final bool isRead;
  final bool isFavorite;

  const HadithItem({
    required this.id,
    required this.text,
    required this.narrator,
    required this.source,
    required this.chapter,
    required this.explanation,
    required this.category,
    this.isRead = false,
    this.isFavorite = false,
  });

  HadithItem copyWith({
    bool? isRead,
    bool? isFavorite,
  }) {
    return HadithItem(
      id: id,
      text: text,
      narrator: narrator,
      source: source,
      chapter: chapter,
      explanation: explanation,
      category: category,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isRead': isRead,
        'isFavorite': isFavorite,
      };
}
