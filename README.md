# dotfiles

Cross-platform declarative configuration (macOS / Arch / NixOS) via Nix flakes +
home-manager. See **DECISIONS.md** for the reasoning behind the structure and
the current migration state.

## Layout

- `flake.nix` — inputs and one `homeConfiguration` per machine (`macbook`,
  `arch`, `nixos`), each built by the `mkHome` helper with its own `system`.
- `home/` — the home-manager (user) layer.
  - `common.nix` — identity + the `imports` list of program modules.
  - `darwin.nix` / `linux.nix` — OS-specific extras; each imports `common.nix`.
  - `hosts/<host>.nix` — picks the OS layer; identity comes from `flake.nix`.
  - `packages/<name>/<name>.nix` — one directory per program.
  - `packages/template.nix` — copy this to add a program.
- `system/` — NixOS system layer (added later, NixOS only).

## Add a program

```sh
mkdir -p home/packages/foo
cp home/packages/template.nix home/packages/foo/foo.nix
# edit foo.nix, then add  ./packages/foo/foo.nix  to imports in home/common.nix
```

## Apply

```sh
home-manager switch --flake ~/.dotfiles#macbook   # or #arch / #nixos
```

## Status

macOS (`macbook`) is live: Nix + flakes installed, `home-manager switch` applied.
Managed programs: **Neovim** (nixCats — plugins/LSPs/treesitter parsers from Nix,
config vendored at `home/packages/neovim/cfg/`), **zsh** (OS-split: macOS filled,
Arch stub pending), **kitty**, **tmux** (Catppuccin/cpu/battery from Nix, no TPM),
and **oh-my-posh**. See **DECISIONS.md** for state, decisions, and the TODO list.
