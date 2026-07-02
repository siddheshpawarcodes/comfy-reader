import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/constants/read_aloud_languages.dart';
import '../../core/theme/dimens.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_platform.dart';
import '../../services/tts_service.dart';

/// Manages read-aloud languages and voices: pick the language for Devanagari,
/// choose/preview a voice per language, and download more offline voices.
class VoicesScreen extends StatefulWidget {
  const VoicesScreen({super.key});

  @override
  State<VoicesScreen> createState() => _VoicesScreenState();
}

class _VoicesScreenState extends State<VoicesScreen> {
  final TtsService _tts = TtsService.instance;

  /// Installed voices per locale, and whether the engine knows the language at
  /// all (available but not installed → offer download).
  final Map<String, List<TtsVoice>> _voices = {};
  final Map<String, bool> _available = {};
  bool _loading = true;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tts.stop(); // silence any in-flight preview
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _tts.voices(refresh: true); // re-read after a possible install
    for (final lang in readAloudLanguages) {
      _voices[lang.locale] = await _tts.voicesForLanguage(lang.locale);
      _available[lang.locale] = _voices[lang.locale]!.isNotEmpty ||
          await _tts.isLanguageAvailable(lang.locale);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _installVoices() async {
    if (_isAndroid) {
      await TtsPlatform.openTtsSettings();
      // The user may have downloaded a voice; refresh when they return.
      await _load();
    } else {
      await _showIosGuide();
    }
  }

  Future<void> _showIosGuide() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download voices'),
        content: const Text(
          'On iPhone/iPad, higher-quality and additional voices are managed by '
          'the system:\n\n'
          'Settings → Accessibility → Spoken Content → Voices\n\n'
          'Tap a language, then download an Enhanced or Premium voice. Note: '
          'iOS provides Indian-language voices only for Hindi — other Indian '
          'languages need the downloadable neural voices (a later update).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Previews [lang] with a specific candidate [voiceName] (null = engine's
  /// automatic pick) without touching the saved preference — lets the user
  /// audition a voice from inside the picker dialog before committing to it.
  Future<void> _previewVoice(ReadAloudLanguage lang, String? voiceName) async {
    await _tts.applyLanguage(lang.locale, preferredVoiceName: voiceName);
    await _tts.speak(lang.sample);
  }

  Future<void> _pickVoice(ReadAloudLanguage lang) async {
    final settings = context.read<SettingsProvider>();
    final voices = _voices[lang.locale] ?? const [];
    final current = settings.voiceByLanguage[lang.locale];

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => _VoicePickerDialog(
        language: lang.name,
        voices: voices,
        selected: current,
        onPreview: (voiceName) => _previewVoice(lang, voiceName),
      ),
    );
    // The dialog returns the chosen voice name, or the sentinel '' for
    // Automatic. `null` means it was cancelled — leave unchanged.
    if (result == null) return;
    await settings.setVoiceForLanguage(lang.locale, result.isEmpty ? null : result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read-aloud voices'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: Dimens.space8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.space4,
                    Dimens.space4,
                    Dimens.space4,
                    0,
                  ),
                  child: Text(
                    'Read-aloud now detects each page’s language and uses a '
                    'matching voice. Download more languages, or pick a '
                    'higher-quality voice below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimens.space4),
                  child: FilledButton.icon(
                    onPressed: _installVoices,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      _isAndroid ? 'Download / manage voices' : 'How to add voices',
                    ),
                  ),
                ),

                SwitchListTile(
                  secondary: const Icon(Icons.translate_rounded),
                  title: const Text('Auto-detect language'),
                  subtitle: const Text(
                    'Choose the voice from each page’s script automatically',
                  ),
                  value: settings.autoDetectLanguage,
                  onChanged: context.read<SettingsProvider>().setAutoDetectLanguage,
                ),

                // Devanagari is shared by Hindi and Marathi — let the user say
                // which one their books are in.
                const _SectionHeader('Devanagari pages'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'hi-IN', label: Text('Hindi')),
                      ButtonSegment(value: 'mr-IN', label: Text('Marathi')),
                    ],
                    selected: {settings.devanagariLanguage},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => context
                        .read<SettingsProvider>()
                        .setDevanagariLanguage(s.first),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.space4,
                    Dimens.space2,
                    Dimens.space4,
                    0,
                  ),
                  child: Text(
                    'Hindi and Marathi use the same script, so this picks which '
                    'one Devanagari text is read as.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // When Marathi is selected but the device has no offline Marathi
                // voice, read-aloud falls back to the Hindi voice — explain why
                // the accent won't be native.
                if (settings.devanagariLanguage == 'mr-IN' &&
                    !(_voices['mr-IN'] ?? const []).any((v) => v.offline))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimens.space4,
                      Dimens.space2,
                      Dimens.space4,
                      0,
                    ),
                    child: Text(
                      'No Marathi voice is installed on this device, so Marathi '
                      'is read with the Hindi voice (a Hindi accent). Install a '
                      'Marathi voice above for native pronunciation if your '
                      'device offers one.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                    ),
                  ),

                const _SectionHeader('Languages'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: readAloudLanguages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: Dimens.space3,
                      crossAxisSpacing: Dimens.space3,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, i) {
                      final lang = readAloudLanguages[i];
                      return _LanguageTile(
                        language: lang,
                        voices: _voices[lang.locale] ?? const [],
                        available: _available[lang.locale] ?? false,
                        selectedVoice: settings.voiceByLanguage[lang.locale],
                        onTap: () => _pickVoice(lang),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// One language as a square tile: script symbol, name, and a status-colored
/// hint. Tapping opens the voice picker dialog (disabled until the language
/// has at least one installed voice).
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.voices,
    required this.available,
    required this.selectedVoice,
    required this.onTap,
  });

  final ReadAloudLanguage language;
  final List<TtsVoice> voices;
  final bool available;
  final String? selectedVoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final installed = voices.isNotEmpty;
    final hasOffline = voices.any((v) => v.offline);

    final Color accent;
    final String status;
    if (installed) {
      accent = hasOffline ? scheme.primary : scheme.tertiary;
      status = selectedVoice != null ? 'Voice set' : (hasOffline ? 'Auto' : 'Online');
    } else if (available) {
      accent = scheme.tertiary;
      status = 'Download';
    } else {
      accent = scheme.error;
      status = 'Unavailable';
    }

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(Dimens.radiusSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.radiusSmall),
        onTap: installed ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.space2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language.symbol,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Dimens.space1.verticalSpace,
              Text(
                language.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                status,
                style: theme.textTheme.labelSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to choose a voice for a language: a checkbox list with a preview
/// button per voice so the user can audition before committing. Returns the
/// chosen voice name, `''` for Automatic, or `null` if cancelled.
class _VoicePickerDialog extends StatefulWidget {
  const _VoicePickerDialog({
    required this.language,
    required this.voices,
    required this.selected,
    required this.onPreview,
  });

  final String language;
  final List<TtsVoice> voices;
  final String? selected;
  final Future<void> Function(String? voiceName) onPreview;

  @override
  State<_VoicePickerDialog> createState() => _VoicePickerDialogState();
}

class _VoicePickerDialogState extends State<_VoicePickerDialog> {
  late String _selected = widget.selected ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('${widget.language} voice'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _selected == '',
              title: const Text('Automatic (best available)'),
              onChanged: (_) => setState(() => _selected = ''),
              secondary: IconButton(
                tooltip: 'Preview',
                icon: const Icon(Icons.play_circle_outline_rounded),
                onPressed: () => widget.onPreview(null),
              ),
            ),
            for (final voice in widget.voices)
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: _selected == voice.name,
                title: Text(voice.name),
                subtitle: Text(
                  '${voice.offline ? 'Offline (recommended)' : 'Online'} · '
                  'quality ${voice.quality}',
                  style: theme.textTheme.bodySmall,
                ),
                onChanged: (_) => setState(() => _selected = voice.name),
                secondary: IconButton(
                  tooltip: 'Preview',
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  onPressed: () => widget.onPreview(voice.name),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

/// A small, muted section header (mirrors the one in `settings_screen.dart`).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.space4,
        Dimens.space6,
        Dimens.space4,
        Dimens.space2,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
