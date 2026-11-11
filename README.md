# muse-omarchy

Meta's [Muse](https://muse.ai) has no Linux app. This gives it a native-feeling home on Omarchy: its own window that tiles like any other app and that you show and hide with one key, plus an entry in the app launcher.

It is the real muse.ai site in a Chromium app window, signed in the normal way. Nothing is scraped or automated. See [PLAN.md](PLAN.md) for the reasoning and the options that were ruled out.

This is an unofficial project and is not affiliated with Meta.

## Install

From a checkout, for the current user:

```sh
./install.sh
```

Or as a system package, the way Omarchy apps are installed:

```sh
cd pkgbuild && makepkg -fsi
```

Needs Omarchy with its Lua Hyprland config and a Chromium-based browser. To remove a checkout install, run `./install.sh --uninstall`. See [PUBLISHING.md](PUBLISHING.md) for how to publish it.

## Use

```sh
muse-omarchy toggle    # show or hide Muse, starting it if needed
muse-omarchy quit      # close Muse to free its memory
```

No key is bound by default. Each user picks their own:

```sh
muse-omarchy set key "SUPER + SHIFT + M"   # "" removes the binding
```

Other settings, stored in `~/.config/muse-omarchy/config`:

```sh
muse-omarchy set profile isolated   # separate browser profile and sign-in; default is "shared"
muse-omarchy show
```

A profile change applies the next time the Muse window is opened.

## How it works

- `share/muse.lua` runs inside Hyprland. It holds the toggle: not running, launch; focused, park it on a hidden workspace; hidden, bring it to the workspace you are on; open elsewhere, focus it. A key press therefore starts no process unless Muse has to be launched.
- `bin/muse-omarchy` is the command line. `toggle` and `quit` ask Hyprland to run the same functions; `set` writes your settings.
- Hyprland config is per user, so the first toggle adds one line to your `~/.config/hypr/hyprland.lua` (with a backup) to load the module. `muse-omarchy remove` takes it out.

## Resource use

- With the shared profile, Muse is one more window of the browser you already have running.
- The isolated profile starts a second, separate browser, which costs noticeably more memory.
- A hidden Muse stays loaded so it returns instantly. `muse-omarchy quit` closes it when you want the memory back.
