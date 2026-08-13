# Dotfiles — Key Decisions & State

Working log so any future session (in `~/.dotfiles`) can pick up with full
context. Read this first.

## Goal

One declarative, reproducible config for **Neovim, tmux, kitty, zsh** (and more
over time) that deploys identically to **macOS (Apple Silicon), Arch Linux, and
NixOS**.

## Current status

- **macOS (`macbook`) is live.** Nix is installed (flakes enabled via
  `~/.config/nix/nix.conf`); `home-manager switch` has been run and the
  home-manager profile is active (`~/.nix-profile/bin/{nvim,vim,vi,home-manager}`).
- **Neovim is fully managed by nixCats** (see below) — plugins, LSPs, and
  treesitter parsers all come from Nix; the lua tree lives at
  `home/packages/neovim/cfg/`. The old standalone repo at `~/.config/nvim` was
  vendored in and backed up to `~/.config/nvim.pre-nixcats` (safe to delete once
  you're happy).
- **zsh, kitty, tmux, and ohmyposh are now managed too** (all imported in
  `common.nix`). The real macOS configs were folded in; the previous `~/.zshrc`,
  `~/.zprofile`, `~/.zshenv`, and `~/.config/tmux/tmux.conf` were backed up to
  `*.backup` on first `switch -b backup`. zsh is OS-split (see §7).
- Identity is set for all three hosts: `macbook` =
  `augusto.carneiro`/`/Users/augusto.carneiro`; `arch` and `nixos` =
  `carneiro`/`/home/carneiro`. The Linux configs evaluate but have not been
  built/activated on a real Linux machine yet.

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
- **kitty** → native module with the real `kitty.conf` kept verbatim via
  `extraConfig = builtins.readFile ./kitty.conf` (it mixes settings, keymaps and
  an include, so a raw file beats the typed `settings` map). The two kittens are
  placed next to it via `xdg.configFile`.
- **zsh** → native `programs.zsh`, **OS-split** (see §7).
- **tmux** → native module, co-located `tmux.conf` via `readFile`; plugins from
  nixpkgs but loaded last (see §8).
- **ohmyposh** → `pkgs.oh-my-posh` + verbatim `config.toml` via `xdg.configFile`
  + a zsh `eval` in `initContent` (NOT `programs.oh-my-posh`, which would force
  re-encoding the TOML as a Nix attrset).
- **Neovim** → NOT expressed in Nix at all (see below). This is the deliberate
  exception, because its config is a full Lua program and forcing it into Nix
  is where sunk-cost / escape-hatch pain lives.

### 5. Neovim: fully managed by nixCats (DONE)
The Neovim config now lives **inside this repo** at `home/packages/neovim/cfg/`
(vendored from the old github.com/cwrneiro/nvim repo, which is retired). nixCats
owns everything via its home-manager module (`inputs.nixCats.homeModule`), wired
in `home/packages/neovim/neovim.nix`:
- **Plugin management: lazy.nvim wrapper.** The `lua/plugins/*.lua` specs are kept
  as-is; `cfg/init.lua` calls `require("nixCatsUtils.lazyCat").setup(...)` so
  lazy.nvim loads plugins from the Nix store instead of cloning. Plugins are
  declared in Nix `categoryDefinitions` (neovim.nix) **and** in the lua specs —
  keep both in sync when adding one. (Chosen over pure-nixCats/lze to avoid
  rewriting the whole plugin layer; over nixvim to avoid Lua-in-Nix-strings.)
- **Nix-only; Mason removed.** `mason.nvim`/`mason-lspconfig.nvim` were deleted
  from `lsp.lua`; LSPs (`rust-analyzer`, `pyright`, `lua-language-server`) come
  from `lspsAndRuntimeDeps`. `vim.lsp.enable({...})` stays. This clears the NixOS
  Mason footgun and the non-Nix lazy bootstrap was dropped from `init.lua`.
- **wrapRc = true** bakes the config into the wrapped `nvim`, so nixCats does NOT
  symlink `~/.config/nvim` — which is what dissolved the original collision with
  the old `programs.neovim` module. Editing the config now means editing
  `cfg/` and re-running `home-manager switch`.
- `nixpkgs_version = inputs.nixpkgs` so nixCats builds against the same nixpkgs as
  the rest of the flake (where plugin/grammar versions were validated).

### 6. Neovim version → nightly overlay; treesitter parsers from Nix
The config uses nvim-treesitter's `main` branch (needs Neovim **0.12+**), so
`neovim-unwrapped` is pulled from `neovim-nightly-overlay` (currently
v0.13.0-nightly). Our locked **nixpkgs already ships nvim-treesitter `main`**, so
no separate plugin input is needed. `withPlugins` does NOT bundle parsers on the
main branch, so `neovim.nix` assembles a `parser/<lang>.so` bundle from
`vimPlugins.nvim-treesitter.builtGrammars` (a `runCommandLocal`) and puts it on
the runtimepath — `treesitter.lua` no longer runs `:TSUpdate`/`.install()`. The
parser language list lives in `neovim.nix` (`tsGrammars`); keep it in sync with
what `treesitter.lua` expects.

### 7. nixpkgs unstable + `home.stateVersion = "25.05"`
Tracking `nixos-unstable` for current tool versions. `stateVersion` pins
state-migration behavior and must not be bumped casually (it is NOT "the version
of anything"). Note: recent home-manager uses `programs.zsh.initContent`
(older: `initExtra`) — adjust if a version mismatch errors.

### 7. zsh is OS-split across the module layers
zsh config differs a lot between macOS and Arch, so it is split using the fact
that `programs.zsh.initContent`/`shellAliases`/`profileExtra`/`envExtra` **merge**
across modules:
- `home/packages/zsh/zsh.nix` — shared base (enable, completion, autosuggestion,
  syntax highlighting, a few cross-platform aliases). No manual `compinit`
  (`enableCompletion` handles it).
- `home/darwin.nix` — the real macOS config: `profileExtra` (brew, framework
  Python, Obsidian), `envExtra` (uv), and `initContent` via `lib.mkMerge` of a
  `mkBefore` block (homebrew `fpath` + `bashcompinit`, before compinit) and a
  `mkAfter` block (bun, rancher, gcloud, work/ct/tokens work bits).
- `home/linux.nix` — **Arch stub** (`initContent` TODO) awaiting the user's
  Arch `~/.zshrc`.

Consequence: `~/.zshrc` is now a read-only symlink, so tools that self-edit it
(Rancher Desktop, gcloud installer) can't — their lines are baked in Nix and
edited there.

### 8. tmux plugins load LAST (not via `programs.tmux.plugins`)
`programs.tmux.plugins` sources plugins BEFORE `extraConfig`, which breaks two
things: catppuccin v2 reads its `@catppuccin_*` options at load, and tmux-cpu
substitutes the literal `#{ram_percentage}`/`#{cpu_percentage}` tokens found in
`status-left/right` at load. Both need our config in place first. So
`home/packages/tmux/tmux.nix` does NOT use `plugins`; it appends
`run-shell <store>/…/catppuccin.tmux` (+cpu, +battery) to the END of
`extraConfig`, mirroring the ordering the original TPM setup relied on. `gitmux`
is added to PATH for catppuccin's git status module. nixpkgs `tmuxPlugins`:
catppuccin is 2.1.3 (matches the pinned version), cpu, battery.

### 9. macOS: GUI apps copied into ~/Applications for Spotlight
home-manager links GUI apps (kitty) into `~/Applications/Home Manager Apps` as
symlinks into `/nix/store`, which **Spotlight refuses to index** (Cmd+Space can't
find them). A Finder *alias* (mkalias) gets indexed but shows as an ugly "alias".
So `home/darwin.nix`'s `copyNixApps` activation drops a **real copy** of each app
bundle under `~/Applications/Nix Apps` — normal icon, no alias badge. The copy
still references `/nix/store` internally (persists), so it launches. Loops over
every HM-linked app; rebuilt each activation to track store-path bumps.

### 10. Neovim plugin loading: Nix-only, and the migration cleanup
Because plugins come from Nix (lazyCat maps each lazy spec to a dir under the
nixCats pack dir) with `install = { missing = false }` (lazy never git-clones),
two rules apply:
- **Names must match.** lazy derives `plugin.name` from the repo URL; it must
  equal the nixCats pack-dir name (the nixpkgs pname, lowercased). Where they
  differ, set `name = "..."` in the spec. Current overrides: `Comment.nvim` →
  `comment.nvim`, `LuaSnip` → `luasnip`, `monokai-nightasty.nvim` →
  `monokai-nightasty`. macOS's case-insensitive FS hides case-only mismatches;
  **Linux will not**, so keep the `name` overrides.
- **Call `setup()` inside `config`,** never at spec module scope. Lazy-loaded
  (`opt`) plugins aren't on the runtimepath when lazy imports the spec files, so
  a top-level `require("plugin").setup{}` fails. (This bit telescope.)

**One-time migration cleanup (per machine coming from a non-Nix nvim):** delete
leftover plugin state or it shadows the Nix plugins via the native packpath /
lazy dir:
`~/.local/share/nvim/site/pack/*` (old packer), `~/.local/share/nvim/lazy/*`
(old lazy clones). On this Mac they were moved to `*.pre-nixcats` — safe to rm.

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

- [x] Install Nix + enable flakes; `home-manager switch` (macOS). Done.
- [x] Neovim → nixCats (plugins/LSPs/treesitter parsers from Nix; Mason removed;
      config vendored into `home/packages/neovim/cfg/`). Done.
- [x] Migrate real zsh/kitty/tmux configs + add ohmyposh; imports enabled in
      `home/common.nix`; activated with `-b backup`. Done (macOS).
- [x] Seed the Arch zsh layer in `home/linux.nix` (history→shared, bindkeys,
      nvhypr). More Arch `~/.zshrc` bits can still be added as they surface.
- [ ] Fold `~/.config/hypr` (hyprland) into the dotfiles as a Linux-only module,
      then repoint the `nvhypr` alias at the vendored path (like `nvconf`).
- [ ] On macOS, verify kitty picks up JetBrains Mono Nerd Font from
      `~/Library/Fonts` (Font Book may need a re-scan / relogin).
- [ ] Commit the nixCats migration (currently only staged, not committed).
- [ ] Archive / redirect the old `github.com/cwrneiro/nvim` repo (now vendored here).
- [x] Removed the pre-nixCats backups (`~/.config/nvim.pre-nixcats`, and
      `~/.local/share/nvim/{lazy,site-pack}.pre-nixcats` + shell `*.backup`).
- [x] Set real usernames/home dirs for `arch`/`nixos` (`carneiro`/`/home/carneiro`).
- [ ] Build/activate on a real Linux machine
      (`nix build .#homeConfigurations.arch.activationPackage`) — evaluates, untested.
- [ ] Add a Nerd Font package (e.g. `nerd-fonts.hack`) if icons render wrong
      (`have_nerd_font = true` is already set in `neovim.nix`).

## How to apply (once Nix is installed)

```sh
home-manager switch --flake ~/.dotfiles#macbook   # macOS
home-manager switch --flake ~/.dotfiles#arch      # Arch
home-manager switch --flake ~/.dotfiles#nixos     # NixOS (user layer)
```
