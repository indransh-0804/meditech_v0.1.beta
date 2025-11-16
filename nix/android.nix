{androidenv}:
androidenv.composeAndroidPackages {
  cmdLineToolsVersion = "11.0";
  toolsVersion = "26.1.1";
  platformToolsVersion = "35.0.1";
  buildToolsVersions = ["30.0.3" "33.0.1" "34.0.0" "35.0.0"];
  platformVersions = ["31" "33" "34" "35" "36"];
  abiVersions = ["x86_64" "armeabi-v7a" "arm64-v8a"];
  includeEmulator = false;
  emulatorVersion = "35.1.4";
  includeSystemImages = false;
  systemImageTypes = ["google_apis_playstore"];
  includeSources = false;
  includeNDK = true;
  ndkVersions = ["27.0.12077973"];
  cmakeVersions = ["3.22.1"];
  extraLicenses = [
    "android-sdk-license"
    "android-sdk-preview-license"
    "google-gdk-license"
    "intel-android-extra-license"
  ];
}
