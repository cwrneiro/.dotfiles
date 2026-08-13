# Dotfiles — Key Decisions & State

Working log so any future session (in `~/.dotfiles`) can pick up with full
context. Read this first.

## Goal

One declarative, reproducible config for **Neovim, tmux, kitty, zsh** (and more
over time) that deploys identically to **macOS (Apple Silicon), Arch Linux, and
NixOS**.

## Current status (Phase 1 scaffold)

- Scaffold written; **not yet built or validated** — Nix is **not installed** on
  this machine yet. First real step next session: install Nix, then
  `home-manager switch`.
- Only the macOS (`macbook`) config has real identity values. `arch` and
  `nixos` have **placeholder** username/homeDirectory (`augusto` / `/home/augusto`)
  — marked `TODO` in `flake.nix`.

## Architecture decisions

### 1. home-manager standalone (not nix-darwin / NixOS module)
home-manager manages itself (`programs.home-manager.enable = true`) so the exact
same user config runs on macOS and Arch (non-NixOS) as well as NixOS. NixOS
*system-level* config (if/when needed) lives separately under `system/` and is
wired as a `nixosConfiguration`, not mixed into the user layer.

### 2. Multi-system flake via one `mkHome` helper
The reference repo (codeberg justgivemeaname/.dotfiles) hardcoded a single
`system = "x86_64-linux"`. We generalized: `mkHome` takes `system` per
`homeConfiguration`, so `macbook` = `aarch64-darwin`, `arch`/`nixos` =
`x86_64-linux`. This was the single biggest change from the reference.

### 3. Per-program module directories (adopted from reference repo)
`home/packages/<name>/<name>.nix`, aggregated by a one-line `imports` list in
`home/common.nix`. Toggle a program by (un)commenting its import. `template.nix`
scaffolds new ones. This is the organization we liked.

### 4. Config-file strategy per program (the "escape hatch" answer)
We pick the lowest-friction representation per tool, on purpose:
- **kitty** → typed `programs.kitty.settings` (pure key=value, lossless).
- **zsh** → native `programs.zsh` module (+ `initContent` for raw lines).
- **tmux** → native module but config kept as a **co-located `tmux.conf`** read
  via `builtins.readFile` (demonstrates the file-based pattern).
- **Neovim** → NOT expressed in Nix at all (see below). This is the deliberate
  exception, because its config is a full Lua program and forcing it into Nix
  is where sunk-cost / escape-hatch pain lives.

### 5. Neovim: environment-only in Phase 1; nixCats in Phase 2
- The Neovim config is its **own repo** at `~/.config/nvim`
  (github.com/cwrneiro/nvim). Phase 1 does **not** symlink or copy it. Nix only
  provides neovim + LSPs + tools (`home/packages/neovim/neovim.nix`), replacing
  Mason and the implicit PATH deps. lazy.nvim keeps managing plugins.
- **Mason must be removed** from the nvim config before NixOS use (Mason's
  prebuilt binaries don't run on NixOS). Not done yet — tracked in TODOs.
- **Phase 2 = nixCats**: Nix manages plugins/LSPs/treesitter grammars too, while
  the `lua/` tree stays real `.lua` files (chosen over nixvim specifically to
  avoid Lua-in-Nix-strings). Open question: consume the nvim repo as a flake
  input vs git submodule vs relocate into `~/.dotfiles`.

### 6. Neovim version → nightly overlay
The nvim config uses nvim-treesitter's `main` branch, which needs Neovim
**0.12+**. nixpkgs usually trails, so `neovim-nightly-overlay` is a flake input
and the neovim package is pulled from it. If we later pin nvim-treesitter to the
`master` branch, we could drop the overlay and use nixpkgs neovim.

### 7. nixpkgs unstable + `home.stateVersion = "25.05"`
Tracking `nixos-unstable` for current tool versions. `stateVersion` pins
state-migration behavior and must not be bumped casually (it is NOT "the version
of anything"). Note: recent home-manager uses `programs.zsh.initContent`
(older: `initExtra`) — adjust if a version mismatch errors.

## Repo layout

```
~/.dotfiles/
├── flake.nix                       # inputs + per-host mkHome (multi-system)
├── DECISIONS.md                    # this file
├── README.md                       # apply commands + workflow
├── home/
│   ├── common.nix                  # identity + imports aggregator
│   ├── darwin.nix                  # macOS extras (clang) -> imports common
│   ├── linux.nix                   # Arch+NixOS extras (gcc, xdg-utils)
│   ├── hosts/
│   │   ├── macbook.nix             # -> darwin.nix
│   │   ├── arch.nix                # -> linux.nix
│   │   └── nixos.nix               # -> linux.nix
│   └── packages/
│       ├── template.nix            # copy to add a program
│       ├── neovim/neovim.nix       # env only (Phase 1)
│       ├── zsh/zsh.nix
│       ├── kitty/kitty.nix
│       └── tmux/{tmux.nix,tmux.conf}
└── system/                         # (later) NixOS system layer
```

## TODOs / open items

- [ ] Install Nix (Determinate Systems installer recommended on macOS) + enable
      flakes; then `home-manager switch --flake ~/.dotfiles#macbook`.
- [ ] Confirm real usernames/home dirs for `arch` and `nixos` in `flake.nix`.
- [ ] Verify the nightly neovim attribute path
      (`inputs.neovim-nightly-overlay.packages.<system>.default`) resolves; adjust
      if the overlay's attr name differs.
- [ ] Remove Mason from `~/.config/nvim` (mason.nvim + mason-lspconfig) and
      enable the servers directly, before any NixOS run.
- [ ] Migrate real zsh/kitty/tmux configs into the starter modules.
- [ ] Decide Phase 2 nixCats consumption of the nvim repo (input/submodule/relocate).
- [ ] Add a Nerd Font package (e.g. `nerd-fonts.hack`) if icons render wrong.

## How to apply (once Nix is installed)

```sh
home-manager switch --flake ~/.dotfiles#macbook   # macOS
home-manager switch --flake ~/.dotfiles#arch      # Arch
home-manager switch --flake ~/.dotfiles#nixos     # NixOS (user layer)
```
