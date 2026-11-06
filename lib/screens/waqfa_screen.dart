import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/accountability_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/storage_service.dart';
import '../data/sunan_data.dart';

class WaqfaScreen extends StatefulWidget {
  final AccountabilityController controller;
  final SettingsController settingsController;

  const WaqfaScreen({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  @override
  State<WaqfaScreen> createState() => _WaqfaScreenState();
}

class _WaqfaScreenState extends State<WaqfaScreen> {
  late TextEditingController _proudOfCtrl;
  late TextEditingController _shortfallCtrl;
  late TextEditingController _fixTomorrowCtrl;
  late TextEditingController _duaaCtrl;

  final Map<String, TextEditingController> _questionControllers = {};
  final Set<String> _selectedTomorrowGoals = {};

  bool _reminderEnabled = true;
  String _reminderTime = '21:30';

  final List<String> _questions = [
    'هل أديت الصلوات في أوقاتها؟',
    'ما العبادة التي قصّرت فيها اليوم؟',
    'هل أخطأت في حق أحد؟',
    'هل وقعت في غيبة أو نميمة؟',
    'ما العمل الصالح الذي أسعدني اليوم؟',
    'ما الذنب الذي أحتاج إلى التوبة منه والاستغفار؟',
    'ما العمل الذي سأجتهد في تحسينه غداً؟',
  ];

  final List<String> _suggestedGoals = [
    'المحافظة على صلاة الفجر في جماعة',
    'قراءة وِرد القرآن الكريم بتدبر',
    'المحافظة على أذكار الصباح والمساء كاملة',
    'أداء السنن الرواتب الاثنتي عشرة كاملة',
    'إخراج صدقة ولو بالقليل',
    'بر الوالدين وصلة الرحم والاطمئنان عليهم',
    'حفظ اللسان من اللغو والغيبة',
    'قيام الليل وصلاة الوتر قبل النوم',
  ];

  @override
  void initState() {
    super.initState();
    final rec = widget.controller.currentWaqfaRecord;

    _proudOfCtrl = TextEditingController(text: rec?.proudOf ?? '');
    _shortfallCtrl = TextEditingController(text: rec?.shortfall ?? '');
    _fixTomorrowCtrl = TextEditingController(text: rec?.fixTomorrow ?? '');
    _duaaCtrl = TextEditingController(text: rec?.duaaOrIntention ?? '');

    for (final q in _questions) {
      _questionControllers[q] = TextEditingController(text: rec?.answers[q] ?? '');
    }

    if (rec != null) {
      _selectedTomorrowGoals.addAll(rec.tomorrowGoals);
    } else {
      _selectedTomorrowGoals.addAll([
        'المحافظة على صلاة الفجر في جماعة',
        'المحافظة على أذكار الصباح والمساء كاملة',
        'قراءة وِرد القرآن الكريم بتدبر',
      ]);
    }

    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final enabled = await StorageService.instance.isWaqfaReminderEnabled();
    final time = await StorageService.instance.getWaqfaReminderTime();
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = time;
      });
    }
  }

  @override
  void dispose() {
    _proudOfCtrl.dispose();
    _shortfallCtrl.dispose();
    _fixTomorrowCtrl.dispose();
    _duaaCtrl.dispose();
    for (final c in _questionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveWaqfaSession() async {
    final answers = <String, String>{};
    _questionControllers.forEach((q, ctrl) {
      if (ctrl.text.trim().isNotEmpty) {
        answers[q] = ctrl.text.trim();
      }
    });

    await widget.controller.saveWaqfa(
      proudOf: _proudOfCtrl.text.trim(),
      shortfall: _shortfallCtrl.text.trim(),
      fixTomorrow: _fixTomorrowCtrl.text.trim(),
      duaaOrIntention: _duaaCtrl.text.trim(),
      answers: answers,
      tomorrowGoals: _selectedTomorrowGoals.toList(),
    );

    if (mounted) {
      widget.settingsController.triggerCompletionFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ وقفة اليوم ومراجعة النفس بنجاح، تقبل الله منك.',
            style: AppTheme.getCairoFont(),
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _showReminderDialog() async {
    final parts = _reminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 21,
      minute: int.tryParse(parts[1]) ?? 30,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryGreen,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';
      await StorageService.instance.setWaqfaReminderTime(newTime);
      if (mounted) {
        setState(() {
          _reminderTime = newTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'وقفة مع نفسك',
            style: AppTheme.getArabicFont(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined),
              tooltip: 'تذكير وقفة مع نفسك',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'تذكير وقفة مع نفسك',
                            style: AppTheme.getCairoFont(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: Text('تفعيل التذكير المسائي', style: AppTheme.getCairoFont()),
                            value: _reminderEnabled,
                            activeThumbColor: AppTheme.goldAccent,
                            onChanged: (val) async {
                              await StorageService.instance.setWaqfaReminderEnabled(val);
                              if (mounted) {
                                setState(() => _reminderEnabled = val);
                              }
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                            },
                          ),
                          ListTile(
                            title: Text('وقت التذكير', style: AppTheme.getCairoFont()),
                            subtitle: Text(_reminderTime, style: AppTheme.getCairoFont(color: AppTheme.goldAccent)),
                            trailing: const Icon(Icons.access_time_rounded),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showReminderDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.save_rounded),
              tooltip: 'حفظ المراجعة',
              onPressed: _saveWaqfaSession,
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة المقولة الإيمانية المشجعة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF142C21), const Color(0xFF0F1E17)]
                        : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.self_improvement_rounded, size: 36, color: AppTheme.goldAccent),
                    const SizedBox(height: 10),
                    Text(
                      '«حَاسِبُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا، وَزِنُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُوزَنُوا، وَأَصْلِحْ مَا بَيْنَكَ وَبَيْنَ اللَّهِ؛ فَكُلُّ يَوْمٍ جَدِيدٍ فُرْصَةٌ لِلتَّوْبَةِ وَالْبِدَايَةِ مِنْ جَدِيدٍ».',
                      textAlign: TextAlign.center,
                      style: AppTheme.getArabicFont(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                        color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. ملخص اليوم تلقائياً
              Text(
                '1. ملخص ما أنجزته اليوم تلقائياً:',
                style: AppTheme.getCairoFont(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildAutomaticSummary(isDark),

              const SizedBox(height: 24),

              // 2. أسئلة محاسبة النفس
              Text(
                '2. أسئلة للتأمل ومحاسبة النفس:',
                style: AppTheme.getCairoFont(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 10),
              ..._questions.map((q) => _buildQuestionCard(isDark, q)),

              const SizedBox(height: 24),

              // 3. مساحة الكتابة الشخصية
              Text(
                '3. مساحتك الشخصية للخواطر والمحاسبة:',
                style: AppTheme.getCairoFont(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildPersonalWritingField(
                isDark: isDark,
                controller: _proudOfCtrl,
                title: 'أكثر شيء أفتخر بإنجازه اليوم:',
                hint: 'مثال: صليت الفجر جماعة، بررت والدي، كظمت غيظي...',
                icon: Icons.emoji_events_outlined,
              ),
              const SizedBox(height: 12),
              _buildPersonalWritingField(
                isDark: isDark,
                controller: _shortfallCtrl,
                title: 'تقصيري اليوم الذي أستغفر الله منه:',
                hint: 'مثال: ضيعت وقتاً طويلاً، تأخرت عن الصلاة، نسيت الأذكار...',
                icon: Icons.sentiment_dissatisfied_outlined,
              ),
              const SizedBox(height: 12),
              _buildPersonalWritingField(
                isDark: isDark,
                controller: _fixTomorrowCtrl,
                title: 'ما الذي أريد إصلاحه وتغييره غداً؟',
                hint: 'مثال: النوم مبكراً، البكور للمسجد، حفظ لساني...',
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 12),
              _buildPersonalWritingField(
                isDark: isDark,
                controller: _duaaCtrl,
                title: 'دعاء أو نية أبدأ بها يومي القادم:',
                hint: 'اللهم إني أسألك علماً نافعاً ورزقاً طيباً وعملاً متقبلاً...',
                icon: Icons.volunteer_activism_outlined,
              ),

              const SizedBox(height: 24),

              // 4. خطة الغد وأهدافه
              Text(
                '4. خطتي وأهدافي لليوم التالي:',
                style: AppTheme.getCairoFont(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildTomorrowGoals(isDark),

              const SizedBox(height: 24),

              // زر حفظ الجلسة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveWaqfaSession,
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    'حفظ جلسة وقفة مع نفسك لليوم',
                    style: AppTheme.getCairoFont(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutomaticSummary(bool isDark) {
    final prayerLog = widget.controller.currentPrayerLog;
    final deedsLog = widget.controller.currentDeedsLog;
    final tasbeehLog = widget.controller.currentTasbeehLog;

    final prayed = prayerLog?.totalPrayedCount ?? 0;
    final jamaah = prayerLog?.jamaahCount ?? 0;

    var sunanCount = 0;
    if (prayerLog != null) {
      for (final s in SunanData.allSunan) {
        if (prayerLog.sunanStatus[s.id] == true) sunanCount += s.rakahs;
      }
    }

    final totalTasbeeh = tasbeehLog?.totalAllToday ?? 0;
    final deeds = deedsLog?.completedCount ?? 0;
    final isHadithRead = widget.controller.readHadithIds.contains(widget.controller.todayHadith.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('الصلوات الخمس المفروضة:', '$prayed من 5 ($jamaah صلوات جماعة)', isDark),
          const Divider(height: 12),
          _buildSummaryRow('السنن الرواتب والمستحبة:', '$sunanCount ركعة نافلة', isDark),
          const Divider(height: 12),
          _buildSummaryRow('التسبيح والذكر والاستغفار:', '$totalTasbeeh تسبيحة وذكر', isDark),
          const Divider(height: 12),
          _buildSummaryRow('الأعمال الصالحة المسجلة:', '$deeds عملاً صالحاً', isDark),
          const Divider(height: 12),
          _buildSummaryRow('حديث اليوم النبوي:', isHadithRead ? 'تمت قراءته بحمد الله' : 'لم يُقرأ بعد', isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.getCairoFont(fontSize: 12.5, color: isDark ? Colors.white70 : Colors.black87)),
        Text(value, style: AppTheme.getCairoFont(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
      ],
    );
  }

  Widget _buildQuestionCard(bool isDark, String question) {
    final ctrl = _questionControllers[question]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: 16, color: AppTheme.goldAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: AppTheme.getCairoFont(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            style: AppTheme.getCairoFont(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'اكتب تأملك أو إجابتك هنا...',
              hintStyle: AppTheme.getCairoFont(fontSize: 12, color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalWritingField({
    required bool isDark,
    required TextEditingController controller,
    required String title,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.getCairoFont(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 2,
            style: AppTheme.getCairoFont(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.getCairoFont(fontSize: 12, color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowGoals(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: _suggestedGoals.map((goal) {
          final isSelected = _selectedTomorrowGoals.contains(goal);
          return CheckboxListTile(
            value: isSelected,
            activeColor: AppTheme.primaryGreen,
            title: Text(goal, style: AppTheme.getCairoFont(fontSize: 13)),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedTomorrowGoals.add(goal);
                } else {
                  _selectedTomorrowGoals.remove(goal);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
