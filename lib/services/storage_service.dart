import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_model.dart';
import '../models/deeds_model.dart';
import '../models/tasbeeh_model.dart';
import '../models/waqfa_model.dart';
import '../data/deeds_data.dart';
import '../data/sunan_data.dart';

class StorageService {
  static const String _prefixPrayer = 'prayer_log_';
  static const String _prefixDeeds = 'deeds_log_';
  static const String _prefixTasbeeh = 'tasbeeh_log_';
  static const String _prefixWaqfa = 'waqfa_log_';
  static const String _keyCustomDeeds = 'custom_deeds_list';
  static const String _keyReadHadiths = 'read_hadiths_ids';
  static const String _keyFavHadiths = 'fav_hadiths_ids';
  static const String _keyTasbeehAllTime = 'tasbeeh_all_time_totals';
  static const String _keyTasbeehTargets = 'tasbeeh_custom_targets';
  static const String _keyReminderTime = 'waqfa_reminder_time';
  static const String _keyReminderEnabled = 'waqfa_reminder_enabled';

  // Singleton instance
  static final StorageService instance = StorageService._();
  StorageService._();

  // تنسيق التاريخ الافتراضي: YYYY-MM-DD
  static String formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // ===================== الصلوات والسنن =====================

  Future<DayPrayerLog> getPrayerLog(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixPrayer$dateString');

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return DayPrayerLog.fromJson(map);
      } catch (_) {}
    }

    // سجل افتراضي للصلوات الخمس غير مؤداة
    final initialPrayers = {
      'fajr': const PrayerItem(id: 'fajr', name: 'صلاة الفجر'),
      'dhuhr': const PrayerItem(id: 'dhuhr', name: 'صلاة الظهر'),
      'asr': const PrayerItem(id: 'asr', name: 'صلاة العصر'),
      'maghrib': const PrayerItem(id: 'maghrib', name: 'صلاة المغرب'),
      'isha': const PrayerItem(id: 'isha', name: 'صلاة العشاء'),
    };

    final initialSunan = <String, bool>{};
    for (final s in SunanData.allSunan) {
      initialSunan[s.id] = false;
    }

    return DayPrayerLog(
      dateString: dateString,
      prayers: initialPrayers,
      sunanStatus: initialSunan,
    );
  }

  Future<void> savePrayerLog(DayPrayerLog log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixPrayer${log.dateString}', jsonEncode(log.toJson()));
  }

  // ===================== الأعمال اليومية =====================

  Future<List<String>> getCustomDeedsTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCustomDeeds) ?? [];
  }

  Future<void> saveCustomDeedTemplate(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomDeeds) ?? [];
    if (!list.contains(title)) {
      list.add(title);
      await prefs.setStringList(_keyCustomDeeds, list);
    }
  }

  Future<DayDeedsLog> getDeedsLog(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixDeeds$dateString');

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return DayDeedsLog.fromJson(map);
      } catch (_) {}
    }

    // إعداد القائمة الافتراضية مع أية أعمال مخصصة مسبقاً
    final customTitles = await getCustomDeedsTemplates();
    final deeds = <DeedItem>[...DeedsData.defaultDeeds];
    var idCounter = 100;
    for (final title in customTitles) {
      deeds.add(DeedItem(id: idCounter++, title: title, isCustom: true));
    }

    return DayDeedsLog(
      dateString: dateString,
      deeds: deeds,
      notes: '',
    );
  }

  Future<void> saveDeedsLog(DayDeedsLog log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixDeeds${log.dateString}', jsonEncode(log.toJson()));
  }

  // ===================== المسبحة والأذكار =====================

  Future<DayTasbeehLog> getTasbeehLog(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixTasbeeh$dateString');

    final targetsRaw = prefs.getString(_keyTasbeehTargets);
    final targets = <String, int>{};
    if (targetsRaw != null) {
      try {
        final map = jsonDecode(targetsRaw) as Map<String, dynamic>;
        map.forEach((k, v) => targets[k] = v as int);
      } catch (_) {}
    }

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final log = DayTasbeehLog.fromJson(map);
        return DayTasbeehLog(
          dateString: dateString,
          counts: log.counts,
          targets: {...targets, ...log.targets},
        );
      } catch (_) {}
    }

    return DayTasbeehLog(
      dateString: dateString,
      counts: {},
      targets: targets,
    );
  }

  Future<void> saveTasbeehLog(DayTasbeehLog log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixTasbeeh${log.dateString}', jsonEncode(log.toJson()));

    // حفظ الأهداف العامة
    if (log.targets.isNotEmpty) {
      await prefs.setString(_keyTasbeehTargets, jsonEncode(log.targets));
    }
  }

  Future<Map<String, int>> getAllTimeTasbeehTotals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyTasbeehAllTime);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return map.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }
    return {};
  }

  Future<void> incrementAllTimeTasbeeh(String thikrId, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final totals = await getAllTimeTasbeehTotals();
    totals[thikrId] = (totals[thikrId] ?? 0) + amount;
    await prefs.setString(_keyTasbeehAllTime, jsonEncode(totals));
  }

  // ===================== الأحاديث النبوية =====================

  Future<Set<int>> getReadHadithIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyReadHadiths) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toSet();
  }

  Future<void> toggleHadithRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getReadHadithIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_keyReadHadiths, ids.map((e) => e.toString()).toList());
  }

  Future<Set<int>> getFavoriteHadithIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFavHadiths) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toSet();
  }

  Future<void> toggleHadithFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getFavoriteHadithIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_keyFavHadiths, ids.map((e) => e.toString()).toList());
  }

  // ===================== وقفة مع نفسك =====================

  Future<WaqfaRecord?> getWaqfaRecord(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixWaqfa$dateString');
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return WaqfaRecord.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveWaqfaRecord(WaqfaRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixWaqfa${record.dateString}', jsonEncode(record.toJson()));
  }

  // إعدادات التذكير اليومي بوقفة مع نفسك
  Future<bool> isWaqfaReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? true;
  }

  Future<void> setWaqfaReminderEnabled(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, val);
  }

  Future<String> getWaqfaReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReminderTime) ?? '21:30'; // 9:30 مساءً افتراضياً
  }

  Future<void> setWaqfaReminderTime(String timeStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminderTime, timeStr);
  }

  // ===================== المكتبة الإسلامية وحفظ التقدم =====================
  static const String _keyLibraryPosPrefix = 'library_last_pos_';

  Future<int> getLibraryLastPosition(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyLibraryPosPrefix$sectionKey') ?? 1;
  }

  Future<void> saveLibraryLastPosition(String sectionKey, int position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyLibraryPosPrefix$sectionKey', position);
  }
}
