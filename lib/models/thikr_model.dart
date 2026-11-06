/// نموذج بيانات الذكر الواحد
class Thikr {
  final int id;
  final String text;
  final String? source;
  final String reward; // فضل الذكر
  final int targetCount; // عدد مرات التكرار كرقم
  final String countDescription; // وصف التكرار كتابة (مثلاً: مرة واحدة، ثلاث مرات، مائة مرة)
  final String? note; // ملاحظات أو توجيهات إضافية
  final bool isSpecialDuaa; // هل هو الدعاء الختامي لمن أنشأ التطبيق وقارئيه

  const Thikr({
    required this.id,
    required this.text,
    this.source,
    required this.reward,
    required this.targetCount,
    required this.countDescription,
    this.note,
    this.isSpecialDuaa = false,
  });
}
