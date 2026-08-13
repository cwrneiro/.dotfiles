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

Phase 1 scaffold. Nix not yet installed on the primary machine — see the TODO
list in **DECISIONS.md** for the exact next steps.
