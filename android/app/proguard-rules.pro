# Keep all classes and members inside com.ryanheise package (audioservice & just_audio_background)
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio_background.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# Preserve Flutter plugin classes and dynamic callbacks
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Avoid compilation warnings/crashes from missing deferred components/play core library references
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
