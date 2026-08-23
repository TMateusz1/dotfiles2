# AGENTS.md

This file applies to the whole repository. It is the operating contract for AI
agents changing these dotfiles.

## Priorities

1. Preserve a simple, predictable user experience.
2. Keep the terminal, tmux, shell, and Neovim workflow visually and
   behaviorally consistent.
3. Prefer a small, understandable configuration over more features or more
   abstraction.
4. Keep bootstrap safe to rerun on macOS and Ubuntu.

If a technically elegant change makes a common action harder to discover,
slower, noisier, or less predictable, do not make it. Do not add a plugin,
dependency, keymap, background process, or abstraction without a concrete
user-facing benefit.

## Before changing anything

- Read the files that own the behavior and the relevant guide in `docs/`.
- Check `git status --short` and preserve unrelated user changes.
- Trace existing keymaps, commands, and plugin responsibilities before adding
  another way to do the same job.
- Make the smallest coherent change. Do not opportunistically reorganize
  unrelated configuration.
- Do not hand-edit generated or external state such as mise installs,
  Neovim's data directory, or user files outside this repository. Use the
  owning tool only when the requested task requires that state to change.

## Repository ownership

- `mise/config.toml` is the only source of truth for external CLI, runtime,
  formatter, linter, language-server, Neovim, and tmux versions. Neovim must
  use tools from `PATH`; it must not install them through Mason or another
  package manager.
- `nvim/lazy-lock.json` pins Neovim plugins. Update it only when intentionally
  changing plugin versions and review the resulting lockfile diff.
- `bootstrap.sh` installs and links configuration. It must remain idempotent,
  must run as the normal user, and must back up conflicting targets rather than
  overwrite them.
- `.zshrc.local` is the extension point for machine-local shell settings. Do
  not commit host-specific paths, credentials, tokens, account names, or
  secrets.
- Keep `README.md` a short entry point. Put detailed Neovim, mise, and terminal
  behavior in their existing focused documents under `docs/`.

## Neovim structure

- Put plugin specifications in `nvim/lua/plugins/`. The default is one plugin
  per file, named for the plugin or the user-facing capability it owns.
- Group multiple plugins in one file only when they form one inseparable
  workflow or plugin family, such as a completion engine and its sources, a
  test runner and its adapters, or related `mini.nvim` modules. Do not create
  broad dumping grounds such as `ui.lua`, `misc.lua`, or `utils.lua`.
- Keep a plugin's keys, commands, dependencies, options, and short setup logic
  together in its plugin file. Move code to `nvim/lua/config/` only when it is
  substantial domain behavior, shared by more than one plugin, or clearer as
  an independently testable module.
- Use Lazy's declarative `keys`, `cmd`, `event`, and `ft` fields when they make
  loading simpler without changing behavior. Do not add complicated lazy-load
  choreography for negligible startup savings.
- Reuse the established owners: fzf-lua for finding, Neo-tree for browsing,
  Bufferline for open buffers, conform for formatting, nvim-lint for linting,
  and AutoSession for working-directory sessions. Do not add overlapping
  plugins unless replacing an owner completely.
- External tools are optional at Neovim startup. Check executables before
  using them and degrade quietly with one useful message, not repeated errors.
- Keep both `<leader>` and `<localleader>` as `Space`. Before adding a mapping,
  check for conflicts and follow the existing key families in `docs/nvim.md`.
  Every non-obvious mapping needs a concise `desc` and documentation when it
  changes the daily workflow.
- Keep startup and routine editing quiet: no dashboards, promotional messages,
  repeated missing-tool warnings, surprise sessions, or focus-stealing panes.

## User-experience rules

- Optimize the common path first: open a project, find a file, search text,
  edit, format, test, inspect Git changes, and move between tmux and Neovim.
- Preserve muscle memory. Changing or removing a documented key requires a
  clear improvement, a conflict check, and an update to the relevant guide.
- Prefer one obvious command over aliases that expose the same action in
  several places.
- Use sensible defaults and graceful fallback behavior. A missing optional
  tool must not break shell startup, Neovim startup, or bootstrap reruns.
- Avoid perceptible prompt or startup latency. Do not run slow commands on
  every prompt, buffer event, cursor movement, or redraw.
- Keep messages actionable: say what is unavailable, why it matters, and the
  single command or file that fixes it.
- Preserve cross-boundary behavior such as `Ctrl-h/j/k/l`, modified Enter keys,
  OSC52 clipboard access, and terminal/tmux/Neovim true-color support. Changes
  to one layer must be checked through the other layers it crosses.

## Catppuccin Mocha visual contract

Catppuccin Mocha is the repository's visual system, not a loose inspiration.

- Keep Mocha as the sole flavor and use canonical Catppuccin Mocha hex values
  and semantic color names. Do not introduce another theme, flavor, or random
  accent color.
- Preserve the syntax rule documented in `docs/nvim.md`: color names things,
  grey carries grammar, and italics mean non-code. Comments are the only
  intentionally italic code-area text.
- Preserve readable contrast and the chrome hierarchy: code is more prominent
  than comments; comments are more prominent than line numbers, separators,
  and indent guides. Do not solve focus by making all borders bright.
- Use semantic roles consistently: blue for primary actions/focus, green for
  success/additions/strings, red for errors/deletions, yellow or peach for
  warnings/search/constants, and muted overlay/surface colors for secondary
  chrome.
- `kitty/catppuccin-mocha.conf` owns the terminal ANSI palette. When a palette
  role changes, inspect all applicable consumers: `.tmux.conf`, `.zshrc` fzf colors,
  `starship.toml`, `git/delta.gitconfig`, `lazygit/config.yml`,
  `k9s/skins/catppuccin-mocha.yaml`, and
  `nvim/lua/config/catppuccin.lua`.
- Derived tinted backgrounds are allowed only when documented with their
  purpose and adequate contrast. Do not add a generator or theme framework
  merely to remove this small amount of explicit duplication.

## mise upgrades: 72-hour security gate

Apply this gate before changing any version in `mise/config.toml`:

1. Use the latest stable, non-prerelease release only after it has been public
   for at least 72 hours. Verify the release timestamp from the upstream
   project's official release or registry; do not infer age from a version
   number or a search snippet.
2. Read the upstream release notes and official migration notes between the
   pinned and proposed versions. Check the upstream security advisories and
   the relevant GitHub Advisory Database or ecosystem advisory source for both
   the new version and newly disclosed vulnerabilities in the old one.
3. Confirm that the mise backend still resolves to the official upstream
   project. Keep exact pins; do not commit `latest`, floating major versions,
   forks, or a new registry/source without explicit justification. Use
   upstream checksums or signatures when they are published.
4. Do not upgrade when the candidate has an unresolved regression relevant to
   macOS, Ubuntu, shell startup, tmux, Neovim, or this repo's workflows. Record
   a concise reason when intentionally holding a tool back.
5. A fix for a critical or actively exploited vulnerability may bypass the
   72-hour age rule. State the advisory and reason for the exception in the
   change summary, then run the same installation and behavior checks.
6. Update tools in small logical batches. Keep Go toolchain tools compatible
   with the pinned Go version, Node packages compatible with the pinned Node
   version, and Neovim plugins/config compatible with the pinned Neovim
   version.
7. Run `mise install`, confirm the resolved versions with `mise current`, run
   the affected tools' smoke checks, and run `./check.sh`. Only after the
   replacement versions pass may you run `mise prune`; never prune first.

Never use an unreviewed bulk `mise upgrade --bump` result as the change. A tool
upgrade is complete only when its age, notes, advisories, compatibility, and
local behavior have been checked.

## Implementation rules

- Follow the existing style in each file. Shell scripts use strict mode,
  quoted expansions, small named functions, and clear failure messages.
- Keep shell and bootstrap behavior portable across the supported macOS and
  Ubuntu paths. Guard platform-specific commands explicitly.
- Prefer feature detection (`command -v`, version/capability checks) over
  assumptions about what is installed.
- Do not add a dependency when the shell, Neovim, or an existing dependency
  already provides a clear solution.
- Comments must explain a non-obvious constraint or decision, not restate the
  next line. Keep deliberate compatibility and color-rationale comments.
- Never hide a failing check, weaken an assertion, or suppress an error merely
  to make validation pass.
- Never run destructive Git commands, overwrite user configuration, expose
  secrets, or modify unrelated worktree changes.

## Documentation and validation

Behavior and documentation ship together:

- Update `docs/nvim.md` for Neovim behavior, mappings, plugins, or visual rules.
- Update `docs/mise.md` for tool ownership, versions, or maintenance workflow.
- Update `docs/terminals.md` for shell, tmux, terminal, font, key-protocol,
  color, or clipboard behavior.
- Update `README.md` only when installation, repository layout, primary daily
  workflow, or top-level ownership changes.

Run the narrowest relevant check while iterating, then finish every code or
configuration change with:

```bash
git diff --check
./check.sh
```

Also run the checks appropriate to the changed area:

- Neovim Lua: `stylua --check nvim` plus a focused headless assertion for the
  behavior changed.
- Shell: `bash -n`, `zsh -n`, `shellcheck`, and `shfmt -d` as applicable
  (`./check.sh` covers the repository scripts and `.zshrc`).
- Structured config: parse the changed TOML, YAML, JSON, or Git config with the
  existing tools used by `check.sh`.
- tmux or cross-terminal behavior: start an isolated tmux server with this
  config; do not disturb the user's live server.
- Theme changes: compare both terminal palettes and inspect the affected UI in
  a real or headless rendering where possible; syntax validity alone is not a
  visual test.
- mise upgrades: complete the security gate above, install the versions, and
  smoke-test every changed tool.

If a required check cannot run because of the environment or network, report
the exact check and reason. Do not claim it passed. Finish by reviewing the
diff for scope, duplicated behavior, stale documentation, and user-visible
regressions.
