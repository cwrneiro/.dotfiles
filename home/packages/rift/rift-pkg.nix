# Rift — Rust tiling WM for macOS. Wrapped from the upstream *prebuilt* universal
# release binary rather than built from source.
#
# Why prebuilt: rift's build.rs links private system frameworks — SkyLight,
# MultitouchSupport, Carbon — from /System/Library/PrivateFrameworks. nixpkgs
# packages AeroSpace the same way (fetch the release, install it). Building from
# source is also viable (see bromanko/nix-config) with apple-sdk_15, but the
# prebuilt route avoids a long Rust compile.
#
# CRITICAL — code signing: the upstream release binaries are only "linker-signed"
# (the placeholder signature the linker stamps). macOS will *run* a linker-signed
# binary, but `codesign --verify` reports it as "not signed at all", and TCC
# treats it as unsigned — so a granted Accessibility permission never sticks and
# rift prompts forever. We therefore RE-SIGN with a real ad-hoc signature
# (`codesign -s -`), which TCC accepts (this is exactly what nixpkgs' darwin
# fixup does for from-source builds, and what yabai relies on). The signature is
# content-derived and deterministic, so the grant is stable across rebuilds until
# the rift version (hence the binary) changes.
{ stdenvNoCC, fetchurl, lib, darwin }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rift-wm";
  version = "0.5.3";

  src = fetchurl {
    url = "https://github.com/acsandmann/rift/releases/download/v${finalAttrs.version}/rift-universal-macos-${finalAttrs.version}.tar.gz";
    hash = "sha256-rQ1gM79deqtGKm6cXN5NGrhdLUK7QrhCWqhkPYaDh9g=";
  };

  # The tarball is two flat universal (x86_64+arm64) Mach-O binaries — `rift`
  # (the WM daemon) and `rift-cli` (the Mach-IPC client used for scripting /
  # sketchybar) — with no wrapping directory, so unpack in place.
  sourceRoot = ".";

  # sigtool provides a sandbox-usable `codesign`; it shells out to
  # `codesign_allocate`, which lives in cctools (absent from stdenvNoCC).
  nativeBuildInputs = [ darwin.sigtool darwin.cctools ];

  dontConfigure = true;
  dontBuild = true;
  # Keep the default strip/fixup off so nothing mangles the binary between our
  # re-sign and the store output (a modified Mach-O would invalidate the sig).
  dontStrip = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 rift     "$out/bin/rift"
    install -Dm555 rift-cli "$out/bin/rift-cli"
    # Replace the weak linker-signed placeholder with a real ad-hoc signature so
    # macOS TCC will honor the Accessibility grant (see header comment).
    codesign --force --sign - --identifier rift     "$out/bin/rift"
    codesign --force --sign - --identifier rift-cli "$out/bin/rift-cli"
    runHook postInstall
  '';

  meta = {
    description = "Rust tiling window manager for macOS (prebuilt universal release)";
    homepage = "https://github.com/acsandmann/rift";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    mainProgram = "rift";
  };
})
