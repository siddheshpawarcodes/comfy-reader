import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/dimens.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_platform.dart';
import '../../services/tts_service.dart';

/// A read-aloud language we offer voice management for.
class _Language {
  const _Language(this.locale, this.name, this.sample);

  final String locale; // BCP-47, e.g. hi-IN
  final String name;
  final String sample; // short preview phrase in this language's script
}

/// The languages read-aloud targets. Hindi and Marathi share the Devanagari
/// script, so both appear; which one detection uses is the Devanagari toggle.
const List<_Language> _languages = [
  _Language('en-US', 'English', 'This is a sample of the reading voice.'),
  _Language('hi-IN', 'Hindi', 'नमस्ते, यह पढ़ने की आवाज़ का एक नमूना है।'),
  _Language('mr-IN', 'Marathi', 'नमस्कार, हा वाचनाच्या आवाजाचा एक नमुना आहे.'),
  _Language('bn-IN', 'Bengali', 'নমস্কার, এটি পড়ার কণ্ঠস্বরের একটি নমুনা।'),
  _Language('gu-IN', 'Gujarati', 'નમસ્તે, આ વાંચન અવાજનો એક નમૂનો છે.'),
  _Language('pa-IN', 'Punjabi', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਇਹ ਪੜ੍ਹਨ ਦੀ ਆਵਾਜ਼ ਦਾ ਨਮੂਨਾ ਹੈ।'),
  _Language('or-IN', 'Odia', 'ନମସ୍କାର, ଏହା ପଠନ ସ୍ୱରର ଏକ ନମୁନା।'),
  _Language('ta-IN', 'Tamil', 'வணக்கம், இது வாசிப்பு குரலின் ஒரு மாதிரி.'),
  _Language('te-IN', 'Telugu', 'నమస్కారం, ఇది చదివే స్వరం యొక్క ఒక నమూనా.'),
  _Language('kn-IN', 'Kannada', 'ನಮಸ್ಕಾರ, ಇದು ಓದುವ ಧ್ವನಿಯ ಒಂದು ಮಾದರಿ.'),
  _Language('ml-IN', 'Malayalam', 'നമസ്കാരം, ഇത് വായനാ ശബ്ദത്തിന്റെ ഒരു മാതൃകയാണ്.'),
];

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
    for (final lang in _languages) {
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

  Future<void> _preview(_Language lang) async {
    final selected = context.read<SettingsProvider>().voiceByLanguage[lang.locale];
    await _tts.applyLanguage(lang.locale, preferredVoiceName: selected);
    await _tts.speak(lang.sample);
  }

  Future<void> _pickVoice(_Language lang) async {
    final settings = context.read<SettingsProvider>();
    final voices = _voices[lang.locale] ?? const [];
    final current = settings.voiceByLanguage[lang.locale];

    final result = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => _VoicePickerSheet(
        language: lang.name,
        voices: voices,
        selected: current,
      ),
    );
    // The sheet returns the chosen voice name, or the sentinel '' for
    // Automatic. `null` means dismissed without choosing — leave unchanged.
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
                for (final lang in _languages)
                  _LanguageTile(
                    language: lang,
                    voices: _voices[lang.locale] ?? const [],
                    available: _available[lang.locale] ?? false,
                    selectedVoice: settings.voiceByLanguage[lang.locale],
                    onPreview: () => _preview(lang),
                    onTap: () => _pickVoice(lang),
                  ),
              ],
            ),
    );
  }
}

/// One language row: name, status (installed/needs download/unavailable),
/// selected-voice summary, and a preview button.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.voices,
    required this.available,
    required this.selectedVoice,
    required this.onPreview,
    required this.onTap,
  });

  final _Language language;
  final List<TtsVoice> voices;
  final bool available;
  final String? selectedVoice;
  final VoidCallback onPreview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final installed = voices.isNotEmpty;
    final hasOffline = voices.any((v) => v.offline);

    final String status;
    final Color statusColor;
    if (installed) {
      status = hasOffline
          ? (selectedVoice != null
              ? 'Voice: $selectedVoice'
              : '${voices.length} voice${voices.length == 1 ? '' : 's'} · auto')
          : 'Online voice only — download for offline';
      statusColor = hasOffline
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.tertiary;
    } else if (available) {
      status = 'Available — tap Download above to install';
      statusColor = theme.colorScheme.tertiary;
    } else {
      status = 'Not available on this device';
      statusColor = theme.colorScheme.error;
    }

    return ListTile(
      title: Text(language.name),
      subtitle: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
      ),
      trailing: installed
          ? IconButton(
              tooltip: 'Preview',
              icon: const Icon(Icons.play_circle_outline_rounded),
              onPressed: onPreview,
            )
          : Icon(
              available ? Icons.download_for_offline_outlined : Icons.block_rounded,
              color: statusColor,
            ),
      onTap: installed ? onTap : null,
    );
  }
}

/// Bottom sheet to choose a voice for a language. Returns the chosen voice
/// name, `''` for Automatic, or `null` if dismissed.
class _VoicePickerSheet extends StatelessWidget {
  const _VoicePickerSheet({
    required this.language,
    required this.voices,
    required this.selected,
  });

  final String language;
  final List<TtsVoice> voices;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: RadioGroup<String>(
        groupValue: selected ?? '',
        onChanged: (v) => Navigator.of(context).pop(v),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimens.space4,
                0,
                Dimens.space4,
                Dimens.space2,
              ),
              child: Text('$language voice', style: theme.textTheme.titleMedium),
            ),
            const RadioListTile<String>(
              value: '',
              title: Text('Automatic (best available)'),
            ),
            for (final voice in voices)
              RadioListTile<String>(
                value: voice.name,
                title: Text(voice.name),
                subtitle: Text(
                  '${voice.offline ? 'Offline' : 'Online'} · quality ${voice.quality}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
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
