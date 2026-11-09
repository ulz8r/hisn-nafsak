/// نموذج بيانات فضائل الأذكار النبوية
class AthkarVirtue {
  final int id;
  final String title;
  final String category;
  final String hadithText;
  final String narrator;
  final String source;
  final String ruling;
  final String virtueBenefit;
  final List<String> additionalNarrations;

  const AthkarVirtue({
    required this.id,
    required this.title,
    required this.category,
    required this.hadithText,
    required this.narrator,
    required this.source,
    required this.ruling,
    required this.virtueBenefit,
    this.additionalNarrations = const [],
  });
}
