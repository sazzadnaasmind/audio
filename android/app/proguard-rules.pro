# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Keep all classes from javax.xml.stream
-dontwarn javax.xml.stream.**
-keep class javax.xml.stream.** { *; }

# Keep Apache Tika classes
-dontwarn org.apache.tika.**
-keep class org.apache.tika.** { *; }

# Keep XML related classes
-dontwarn javax.xml.**
-keep class javax.xml.** { *; }

# Keep classes that might be referenced by Apache Tika
-dontwarn org.w3c.dom.**
-keep class org.w3c.dom.** { *; }

-dontwarn org.xml.sax.**
-keep class org.xml.sax.** { *; }

# File picker related
-keep class androidx.documentfile.** { *; }
-dontwarn androidx.documentfile.**

# Audio players related
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# AppLovin
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**

# Google Play Core (for deferred components - not used but referenced by Flutter)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Ignore missing Play Core classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

