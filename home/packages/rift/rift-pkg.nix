# Rift — Rust tiling WM for macOS. Wrapped from the upstream *prebuilt* universal
# release binary rather than built from source.
#
# Why prebuilt (this is the crux of the migration): rift's build.rs links private
# system frameworks — SkyLight, MultitouchSupport, Carbon — from
# /System/Library/PrivateFrameworks, which are NOT present in Nix's Apple SDK, so
# a from-source rustPlatform.buildRustPackage fails at link time. nixpkgs packages
# AeroSpace the same way (fetch the signed release and install it). Bonus: keeping
# the upstream binary byte-for-byte preserves its adhoc code signature, which
# macOS requires to execute it on Apple Silicon AND which anchors the
# Accessibility (TCC) permission grant.
{ stdenvNoCC, fetchurl, lib }:

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

  dontConfigure = true;
  dontBuild = true;
  # Do NOT run the default darwin fixup: stripping or re-signing would invalidate
  # the upstream adhoc signature and break both execution and the TCC grant.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 rift     "$out/bin/rift"
    install -Dm555 rift-cli "$out/bin/rift-cli"
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
