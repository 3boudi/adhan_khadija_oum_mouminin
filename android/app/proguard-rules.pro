# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Keep raw resources
-keep class **.R$raw { *; }

# Keep notification sound resources
-keepclassmembers class **.R$raw {
    public static <fields>;
}

# Audio Service
-keep class com.ryanheise.audioservice.** { *; }
