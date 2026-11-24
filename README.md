# dotfiles

My personal dotfiles, managed by Nix + Home-Manager

## Layout

```bash
.
├── flake.nix                   # inputs and one homeConfiguration per machine
└── home/
    ├── common.nix              # common imports and configs between all machines
    ├── darwin.nix              # macos specific configs
    ├── linux.nix               # common linux specific configs
    ├── nixgl.nix               # fix for opengl outside nixos
    ├── packages/               # program definitions and actual dotfiles
    │   └── <package>/          # one directory per program 
    │       └── <package>.nix
    └── hosts/                  # machine specific configs (the homeConfigurations)
        ├── jinbe.nix           # linux + claude code
        ├── macbook.nix         # macbook (surprised?)
        └── zoro.nix            # daily drive, linux + opencode
```

## Programs

 - aerospace
 - claude
 - kitty
 - neovim
 - ohmyposh
 - opencode
 - sketchybar
 - tmux
 - zsh
