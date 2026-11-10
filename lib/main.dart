import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/settings_controller.dart';
import 'controllers/accountability_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController();
  final accountabilityController = AccountabilityController();
  runApp(HisnNafsakApp(
    settingsController: settingsController,
    accountabilityController: accountabilityController,
  ));
}

class HisnNafsakApp extends StatelessWidget {
  final SettingsController settingsController;
  final AccountabilityController accountabilityController;

  const HisnNafsakApp({
    super.key,
    required this.settingsController,
    required this.accountabilityController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'حصن نفسك',
          debugShowCheckedModeBanner: false,
          themeMode: settingsController.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // التوجيه العربي الكامل من اليمين إلى اليسار
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('ar', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomeScreen(
            settingsController: settingsController,
            accountabilityController: accountabilityController,
          ),
        );
      },
    );
  }
}
