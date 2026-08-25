# Rift — i3-style tiling window manager for macOS (macOS-only; would be imported
# from home/darwin.nix). Parallels aerospace.nix: launchd owns startup/keep-alive
# and the config is kept verbatim rather than re-encoded into a Nix attrset.
#
# NOTE: intentionally NOT yet added to home/darwin.nix imports. Wiring it in and
# running `home-manager switch` would start the rift daemon alongside AeroSpace —
# two tiling WMs fighting over the same windows. Migrate deliberately (disable the
# aerospace import in the same switch), never by accident.
{ pkgs, config, lib, ... }:
let
  rift = pkgs.callPackage ./rift-pkg.nix { };
in
{
  home.packages = [ rift ];

  # launchd user agent. rift with no args reads ~/.config/rift/config.toml. The
  # spawned event scripts (sketchybar triggers via rift-cli) inherit this PATH,
  # so it must contain sketchybar + the usual CLI dirs.
  #
  # These settings deliberately match what `rift service install` generates —
  # they are load-bearing, not cosmetic:
  #   - KeepAlive must be CONDITIONAL, not `true`. A window manager exits cleanly
  #     in some situations (e.g. loaded outside the GUI session, where it can't
  #     attach to the window server). Unconditional KeepAlive restarts it every
  #     time, producing an exit-loop where each relaunch re-fires the macOS
  #     Accessibility prompt. Restart only on crash / unsuccessful exit.
  #   - LimitLoadToSessionType = "Aqua" pins the agent to the GUI login session
  #     so rift always has the window server available (this is the actual fix
  #     for the exit-loop above).
  launchd.agents.rift = {
    enable = true;
    config = {
      ProgramArguments = [ "${rift}/bin/rift" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
      Nice = -20; # WM responsiveness; matches upstream
      EnvironmentVariables = {
        PATH =
          "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        RUST_LOG = "error,warn,info";
      };
      StandardOutPath = "/tmp/rift.out.log";
      StandardErrorPath = "/tmp/rift.err.log";
    };
  };

  # Verbatim config.toml with the two store paths substituted in (same approach
  # as aerospace.nix's @sketchybar@ rewrite).
  xdg.configFile."rift/config.toml".text =
    builtins.replaceStrings
      [ "@sketchybar@" "@rift-cli@" ]
      [ "${pkgs.sketchybar}/bin/sketchybar" "${rift}/bin/rift-cli" ]
      (builtins.readFile ./config.toml);
}
