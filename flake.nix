{
  description = "An example project using flutter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk = {
            accept_license = true;
          };
        };
      };
    in {
      devShells.default = let
        android = pkgs.callPackage ./nix/android.nix {};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            firebase-tools
            jdk17
            gradle
            pkg-config
            android.platform-tools
          ];

          shellHook = ''
            export ANDROID_SDK_ROOT="${android.androidsdk}/libexec/android-sdk"
            export ANDROID_HOME="${android.androidsdk}/libexec/android-sdk"
            export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk-bundle"
            export CMAKE_ROOT="$(echo "$ANDROID_SDK_ROOT/cmake/3.22.1".*/bin)"
            export JAVA_HOME="${pkgs.jdk17}"
            export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_SDK_ROOT/build-tools/34.0.0/aapt2"

            export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
            export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
            export PATH="$CMAKE_ROOT:$PATH"
            export PATH="$HOME/.pub-cache/bin:$PATH"

            flutter config --android-sdk "$ANDROID_SDK_ROOT" &>/dev/null

            echo ""
            echo "Initiating FLutter Development Environment!"
            echo ""
          '';
        };
    });
}
