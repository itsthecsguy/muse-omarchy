# muse-omarchy

Meta's [Muse](https://muse.ai) has no Linux app. This gives it a native-feeling home on Omarchy: its own floating window that you show and hide with one key, plus an entry in the app launcher.

It is the real muse.ai site in a Chromium app window, signed in the normal way. Nothing is scraped or automated. See [PLAN.md](PLAN.md) for the reasoning and the options that were ruled out.

## Install

```sh
./install.sh
```

Needs Omarchy with its Lua Hyprland config and a Chromium-based browser. To remove it, run `./install.sh --uninstall`.

## Use

```sh
muse-omarchy toggle    # show or hide Muse, starting it if needed
```

No key is bound by default. Each user picks their own:

```sh
muse-omarchy set key "SUPER + SHIFT + M"   # "" removes the binding
```

Other settings, stored in `~/.config/muse-omarchy/config`:

```sh
muse-omarchy set profile isolated   # separate browser profile and sign-in; default is "shared"
muse-omarchy set size 1100x800      # window size in pixels
muse-omarchy show
```

A profile change applies the next time the Muse window is opened.

## How it works

- `bin/muse-omarchy` launches muse.ai through `omarchy-launch-webapp` and toggles the `special:muse` workspace.
- `hypr/muse.lua` is loaded from `~/.config/hypr/hyprland.lua`. It floats and centers the window on that workspace and binds your key, if you set one.
