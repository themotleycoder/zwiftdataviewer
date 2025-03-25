# Flutter Proguard Rules

# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Kotlin Coroutines
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.SerializationKt
-keep,includedescriptorclasses class io.flutter.**$$serializer { *; }
-keepclassmembers class io.flutter.** {
    *** Companion;
}
-keepclasseswithmembers class io.flutter.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep Strava API related classes
-keep class com.motleycoder.zwiftdataviewer.** { *; }
-keep class com.strava.** { *; }

# Keep URL Launcher
-keep class com.baseflow.permissionhandler.** { *; }
-keep class androidx.lifecycle.** { *; }

# Keep Shared Preferences
-keep class androidx.preference.** { *; }

# Keep Syncfusion Charts
-keep class com.syncfusion.** { *; }

# Keep HTML parser
-keep class org.jsoup.** { *; }

# Keep Riverpod
-keep class androidx.lifecycle.** { *; }

# Keep Google Play Core library
-keep class com.google.android.play.core.** { *; }

# Ignore warnings for Google Play Core library classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# General Android rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the R class and its fields
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep all drawable and mipmap resources
-keep class **.R$drawable {*;}
-keep class **.R$mipmap {*;}
