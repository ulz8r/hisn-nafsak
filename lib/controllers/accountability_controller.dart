import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../models/deeds_model.dart';
import '../models/tasbeeh_model.dart';
import '../models/waqfa_model.dart';
import '../models/hadith_model.dart';
import '../services/storage_service.dart';
import '../data/hadith_data.dart';
import '../data/tasbeeh_data.dart';

class AccountabilityController extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  DayPrayerLog? _currentPrayerLog;
  DayDeedsLog? _currentDeedsLog;
  DayTasbeehLog? _currentTasbeehLog;
  WaqfaRecord? _currentWaqfaRecord;
  Set<int> _readHadithIds = {};
  Set<int> _favoriteHadithIds = {};

  DateTime get selectedDate => _selectedDate;
  String get currentDateString => StorageService.formatDate(_selectedDate);
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  bool get isLoading => _isLoading;
  DayPrayerLog? get currentPrayerLog => _currentPrayerLog;
  DayDeedsLog? get currentDeedsLog => _currentDeedsLog;
  DayTasbeehLog? get currentTasbeehLog => _currentTasbeehLog;
  WaqfaRecord? get currentWaqfaRecord => _currentWaqfaRecord;
  Set<int> get readHadithIds => _readHadithIds;
  Set<int> get favoriteHadithIds => _favoriteHadithIds;

  AccountabilityController() {
    loadDataForDate(_selectedDate);
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    await loadDataForDate(date);
  }

  Future<void> goToPreviousDay() async {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    await loadDataForDate(_selectedDate);
  }

  Future<void> goToNextDay() async {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    // لا نسمح بالذهاب للمستقبل أبعد من اليوم
    if (tomorrow.isBefore(DateTime(now.year, now.month, now.day + 1))) {
      _selectedDate = tomorrow;
      await loadDataForDate(_selectedDate);
    }
  }

  Future<void> loadDataForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    final dateStr = StorageService.formatDate(date);
    _currentPrayerLog = await _storage.getPrayerLog(dateStr);
    _currentDeedsLog = await _storage.getDeedsLog(dateStr);
    _currentTasbeehLog = await _storage.getTasbeehLog(dateStr);
    _currentWaqfaRecord = await _storage.getWaqfaRecord(dateStr);
    _readHadithIds = await _storage.getReadHadithIds();
    _favoriteHadithIds = await _storage.getFavoriteHadithIds();

    _isLoading = false;
    notifyListeners();
  }

  // ==================== إدارة الصلوات الخمس ====================

  Future<void> togglePrayerStatus(String prayerId, {bool? prayed, bool? inJamaah}) async {
    if (_currentPrayerLog == null) return;

    final currentItem = _currentPrayerLog!.prayers[prayerId] ??
        PrayerItem(id: prayerId, name: prayerId);

    final newPrayed = prayed ?? !currentItem.prayed;
    // قاعدة: لا جماعة بدون صلاة
    final newJamaah = newPrayed ? (inJamaah ?? currentItem.inJamaah) : false;

    final updatedPrayers = Map<String, PrayerItem>.from(_currentPrayerLog!.prayers);
    updatedPrayers[prayerId] = currentItem.copyWith(
      prayed: newPrayed,
      inJamaah: newJamaah,
    );

    _currentPrayerLog = DayPrayerLog(
      dateString: _currentPrayerLog!.dateString,
      prayers: updatedPrayers,
      sunanStatus: _currentPrayerLog!.sunanStatus,
    );

    notifyListeners();
    await _storage.savePrayerLog(_currentPrayerLog!);
  }

  Future<void> togglePrayerJamaah(String prayerId) async {
    if (_currentPrayerLog == null) return;
    final currentItem = _currentPrayerLog!.prayers[prayerId];
    if (currentItem == null || !currentItem.prayed) {
      // إذا لم يكن قد صلى، فلا يمكن تفعيل الجماعة
      return;
    }
    await togglePrayerStatus(prayerId, inJamaah: !currentItem.inJamaah);
  }

  // ==================== إدارة السنن الرواتب ====================

  Future<void> toggleSunnahStatus(String sunnahId) async {
    if (_currentPrayerLog == null) return;

    final currentStatus = _currentPrayerLog!.sunanStatus[sunnahId] ?? false;
    final updatedSunan = Map<String, bool>.from(_currentPrayerLog!.sunanStatus);
    updatedSunan[sunnahId] = !currentStatus;

    _currentPrayerLog = DayPrayerLog(
      dateString: _currentPrayerLog!.dateString,
      prayers: _currentPrayerLog!.prayers,
      sunanStatus: updatedSunan,
    );

    notifyListeners();
    await _storage.savePrayerLog(_currentPrayerLog!);
  }

  // ==================== إدارة الأعمال اليومية ====================

  Future<void> toggleDeedStatus(int deedId) async {
    if (_currentDeedsLog == null) return;

    final updatedDeeds = _currentDeedsLog!.deeds.map((d) {
      if (d.id == deedId) {
        return d.copyWith(isCompleted: !d.isCompleted);
      }
      return d;
    }).toList();

    _currentDeedsLog = DayDeedsLog(
      dateString: _currentDeedsLog!.dateString,
      deeds: updatedDeeds,
      notes: _currentDeedsLog!.notes,
    );

    notifyListeners();
    await _storage.saveDeedsLog(_currentDeedsLog!);
  }

  Future<void> addCustomDeed(String title) async {
    if (_currentDeedsLog == null || title.trim().isEmpty) return;

    await _storage.saveCustomDeedTemplate(title.trim());

    final newId = 100 + _currentDeedsLog!.deeds.length;
    final updatedDeeds = List<DeedItem>.from(_currentDeedsLog!.deeds)
      ..add(DeedItem(id: newId, title: title.trim(), isCustom: true));

    _currentDeedsLog = DayDeedsLog(
      dateString: _currentDeedsLog!.dateString,
      deeds: updatedDeeds,
      notes: _currentDeedsLog!.notes,
    );

    notifyListeners();
    await _storage.saveDeedsLog(_currentDeedsLog!);
  }

  Future<void> updateDeedsNotes(String notes) async {
    if (_currentDeedsLog == null) return;

    _currentDeedsLog = DayDeedsLog(
      dateString: _currentDeedsLog!.dateString,
      deeds: _currentDeedsLog!.deeds,
      notes: notes,
    );

    notifyListeners();
    await _storage.saveDeedsLog(_currentDeedsLog!);
  }

  // ==================== إدارة المسبحة والأذكار ====================

  Future<void> incrementTasbeeh(String thikrId, {int delta = 1}) async {
    if (_currentTasbeehLog == null) return;

    final currentCount = _currentTasbeehLog!.counts[thikrId] ?? 0;
    final newCount = currentCount + delta;

    final updatedCounts = Map<String, int>.from(_currentTasbeehLog!.counts);
    updatedCounts[thikrId] = newCount;

    _currentTasbeehLog = DayTasbeehLog(
      dateString: _currentTasbeehLog!.dateString,
      counts: updatedCounts,
      targets: _currentTasbeehLog!.targets,
    );

    notifyListeners();
    await _storage.saveTasbeehLog(_currentTasbeehLog!);
    await _storage.incrementAllTimeTasbeeh(thikrId, delta);
  }

  Future<void> resetTasbeehCounter(String thikrId) async {
    if (_currentTasbeehLog == null) return;

    final updatedCounts = Map<String, int>.from(_currentTasbeehLog!.counts);
    updatedCounts[thikrId] = 0;

    _currentTasbeehLog = DayTasbeehLog(
      dateString: _currentTasbeehLog!.dateString,
      counts: updatedCounts,
      targets: _currentTasbeehLog!.targets,
    );

    notifyListeners();
    await _storage.saveTasbeehLog(_currentTasbeehLog!);
  }

  Future<void> setTasbeehTarget(String thikrId, int target) async {
    if (_currentTasbeehLog == null) return;

    final updatedTargets = Map<String, int>.from(_currentTasbeehLog!.targets);
    updatedTargets[thikrId] = target;

    _currentTasbeehLog = DayTasbeehLog(
      dateString: _currentTasbeehLog!.dateString,
      counts: _currentTasbeehLog!.counts,
      targets: updatedTargets,
    );

    notifyListeners();
    await _storage.saveTasbeehLog(_currentTasbeehLog!);
  }

  // تجميع الإحصائيات حسب التصنيف
  int getCategoryCount(TasbeehCategory cat) {
    if (_currentTasbeehLog == null) return 0;
    var sum = 0;
    for (final thikr in TasbeehData.thikrList.where((t) => t.category == cat)) {
      sum += _currentTasbeehLog!.counts[thikr.id] ?? 0;
    }
    return sum;
  }

  // ==================== إدارة الأحاديث النبوية ====================

  Future<void> toggleHadithRead(int hadithId) async {
    await _storage.toggleHadithRead(hadithId);
    _readHadithIds = await _storage.getReadHadithIds();
    notifyListeners();
  }

  Future<void> toggleHadithFavorite(int hadithId) async {
    await _storage.toggleHadithFavorite(hadithId);
    _favoriteHadithIds = await _storage.getFavoriteHadithIds();
    notifyListeners();
  }

  HadithItem get todayHadith {
    // اختيار حديث اليوم بناءً على اليوم من السنة ليتجدد يومياً بثبات
    final dayOfYear = _selectedDate.difference(DateTime(_selectedDate.year, 1, 1)).inDays;
    final index = dayOfYear % HadithData.bukhariHadiths.length;
    final h = HadithData.bukhariHadiths[index];
    return h.copyWith(
      isRead: _readHadithIds.contains(h.id),
      isFavorite: _favoriteHadithIds.contains(h.id),
    );
  }

  // ==================== وقفة مع نفسك ====================

  Future<void> saveWaqfa({
    required String proudOf,
    required String shortfall,
    required String fixTomorrow,
    required String duaaOrIntention,
    required Map<String, String> answers,
    required List<String> tomorrowGoals,
  }) async {
    final record = WaqfaRecord(
      dateString: currentDateString,
      proudOf: proudOf,
      shortfall: shortfall,
      fixTomorrow: fixTomorrow,
      duaaOrIntention: duaaOrIntention,
      answers: answers,
      tomorrowGoals: tomorrowGoals,
      createdAt: DateTime.now(),
    );

    _currentWaqfaRecord = record;
    notifyListeners();
    await _storage.saveWaqfaRecord(record);
  }
}
