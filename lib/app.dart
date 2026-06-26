import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';
import 'shared/widgets/max_text_scale.dart';

/// Root app: wires providers and the themed router. Storage/audio are already
/// initialized in `main()` before this builds.
class ComfyReaderApp extends StatelessWidget {
  const ComfyReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) =>
              SettingsProvider(SettingsService(StorageService.instance)),
        ),
        ChangeNotifierProvider<LibraryProvider>(
          create: (_) => LibraryProvider()..loadFromStorage(),
        ),
      ],
      child: ScreenUtilInit(
        // Design reference: iPhone X logical size. Spacing/sizing helpers
        // (.verticalSpace, .horizontalSpace, .h, .w, .r, .sp) scale relative
        // to this baseline so layouts stay proportional across screen sizes.
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return MaterialApp.router(
                title: 'Comfy Reader',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.flutterThemeMode,
                routerConfig: appRouter,
                // Bound OS font scaling app-wide so accessibility font sizes
                // can't overflow the chrome. Applied above every routed page.
                builder: (context, child) =>
                    MaxTextScale(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}
