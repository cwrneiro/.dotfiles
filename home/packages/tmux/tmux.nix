# tmux — native module + CO-LOCATED native config file.
#
# This module demonstrates the reference repo's file-based pattern: the real
# config lives in tmux.conf (a normal file you can edit with full syntax
# support) and is read verbatim into the module. Use this pattern for any
# program whose config you'd rather keep as a native dotfile.
{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
