/// A read-aloud language: BCP-47 locale, display name, a single script glyph
/// for compact tile display, and a short preview phrase in its own script.
class ReadAloudLanguage {
  const ReadAloudLanguage(this.locale, this.name, this.symbol, this.sample);

  final String locale;
  final String name;
  final String symbol;
  final String sample;
}

/// Languages read-aloud targets. Hindi and Marathi share the Devanagari
/// script, so both appear as separate entries — which one auto-detection
/// picks is the Devanagari setting, but a user can also pick either directly.
const List<ReadAloudLanguage> readAloudLanguages = [
  ReadAloudLanguage(
      'en-US', 'English', 'A', 'This is a sample of the reading voice.'),
  ReadAloudLanguage(
      'hi-IN', 'Hindi', 'अ', 'नमस्ते, यह पढ़ने की आवाज़ का एक नमूना है।'),
  ReadAloudLanguage(
      'mr-IN', 'Marathi', 'अ', 'नमस्कार, हा वाचनाच्या आवाजाचा एक नमुना आहे.'),
  ReadAloudLanguage(
      'bn-IN', 'Bengali', 'অ', 'নমস্কার, এটি পড়ার কণ্ঠস্বরের একটি নমুনা।'),
  ReadAloudLanguage(
      'gu-IN', 'Gujarati', 'અ', 'નમસ્તે, આ વાંચન અવાજનો એક નમૂનો છે.'),
  ReadAloudLanguage(
      'pa-IN', 'Punjabi', 'ਅ', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਇਹ ਪੜ੍ਹਨ ਦੀ ਆਵਾਜ਼ ਦਾ ਨਮੂਨਾ ਹੈ।'),
  ReadAloudLanguage(
      'or-IN', 'Odia', 'ଅ', 'ନମସ୍କାର, ଏହା ପଠନ ସ୍ୱରର ଏକ ନମୁନା।'),
  ReadAloudLanguage(
      'ta-IN', 'Tamil', 'அ', 'வணக்கம், இது வாசிப்பு குரலின் ஒரு மாதிரி.'),
  ReadAloudLanguage(
      'te-IN', 'Telugu', 'అ', 'నమస్కారం, ఇది చదివే స్వరం యొక్క ఒక నమూనా.'),
  ReadAloudLanguage(
      'kn-IN', 'Kannada', 'ಅ', 'ನಮಸ್ಕಾರ, ಇದು ಓದುವ ಧ್ವನಿಯ ಒಂದು ಮಾದರಿ.'),
  ReadAloudLanguage(
      'ml-IN', 'Malayalam', 'അ', 'നമസ്കാരം, ഇത് വായനാ ശബ്ദത്തിന്റെ ഒരു മാതൃകയാണ്.'),
];
