# google_mlkit_text_recognition's Android glue code references the
# Chinese/Japanese/Korean recognizer classes unconditionally regardless of
# which script packages are actually declared as dependencies. This app only
# uses the Latin and Devanagari scripts (see lib/services/ocr_service.dart),
# so those classes are never on the classpath and R8 fails with "Missing
# class" unless told they're safe to ignore.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
