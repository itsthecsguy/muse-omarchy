# Publishing muse-omarchy

Status on 2026-11-11: the repo is public and [v0.1.0](https://github.com/itsthecsguy/muse-omarchy/releases/tag/v0.1.0) is released. The AUR and Omarchy's own repo are not done yet.

## Is "an Omarchy app" a thing?

Yes. Omarchy apps are ordinary Arch packages. Omarchy runs its own package repository at `pkgs.omarchy.org`, built from recipes in the public GitHub repo [`omacom/omarchy-pkgs`](https://github.com/omacom/omarchy-pkgs), and that repo's README invites package contributions by pull request. A package there can be installed on any Omarchy machine with `omarchy pkg add muse-omarchy` and appears in the app launcher.

This project is now shaped for that: `pkgbuild/PKGBUILD` builds a package containing the command, the Hyprland module, a launcher entry, an icon and the license. `makepkg` builds it cleanly.

Hyprland config is per user, so a system package cannot hook itself in. The first `muse-omarchy toggle` (for example, from the launcher) adds one line to that user's `~/.config/hypr/hyprland.lua`, with a backup. `muse-omarchy remove` takes it out.

## Three ways to publish, lightest first

| Route | Who can install | Effort | Needs approval from |
|---|---|---|---|
| **GitHub release** with `install.sh` | Anyone who clones the repo | Minutes | Nobody |
| **AUR** package | Any Arch or Omarchy user, with `omarchy pkg aur add muse-omarchy` | About an hour, plus an AUR account and SSH key | Nobody, but AUR rules apply |
| **Omarchy's own repo** (`omacom/omarchy-pkgs`) | Every Omarchy user, with `omarchy pkg add muse-omarchy` | A PR and review | Omarchy's maintainers |

Recommended order: GitHub release first, since both other routes build from it. Then the AUR, which needs nobody's sign-off. Then propose it to Omarchy, where acceptance is the maintainers' call. Their repo mostly holds Omarchy's own apps, well-known third-party apps and hardware support, so a small unofficial wrapper may be declined; open an issue to ask before doing the work.

## Steps

Done: the repo is public, the license is MIT, and `v0.1.0` is tagged and released. `aur/PKGBUILD` is the recipe for the next two steps; it builds from the release tarball and has been test-built.

1. **AUR.** Needs an AUR account with an SSH key registered. Then:

   ```sh
   git clone ssh://aur@aur.archlinux.org/muse-omarchy.git aur-muse-omarchy
   cp aur/PKGBUILD aur/.SRCINFO aur-muse-omarchy/
   cd aur-muse-omarchy && git add PKGBUILD .SRCINFO && git commit -m "Initial release 0.1.0" && git push
   ```

2. **Omarchy repo.** Open an issue on `omacom/omarchy-pkgs` asking whether they would take it. If yes: fork it, run `bin/add-package muse-omarchy --local --scaffold`, put `aur/PKGBUILD` in `pkgbuilds/muse-omarchy/`, and set `.omarchy/package.json` so new releases sync without another PR:

   ```json
   {
     "source": "local",
     "upstream": { "watch": { "github": "itsthecsguy/muse-omarchy", "pattern": "v(?P<version>[0-9]+(?:\\.[0-9]+)*)" } }
   }
   ```

   Their README covers the local build and checks to run before opening the PR.

For a later release: bump `pkgver` in both recipes, tag, release, then refresh the checksum with `updpkgsums` and regenerate `aur/.SRCINFO` with `makepkg --printsrcinfo`.

## Things to keep in mind

- **Name and trademark.** "Muse" and its logo belong to Meta. The package is named `muse-omarchy`, describes itself as unofficial, and ships its own plain icon instead of Meta's. Keep it that way, and say "not affiliated with Meta" in the README.
- **Terms of service.** This opens the real muse.ai site in the user's own browser and automates nothing, which is the same as Omarchy's built-in web apps. That is the reason it is safe to share; see PLAN.md.
- **Upstream changes.** The window is found by Chromium's class name for the URL (`chrome-muse.ai__…`). If Meta moves Muse to another address, the URL and pattern in `share/muse.lua` need a release.
- **Browser.** It relies on `omarchy-launch-webapp`, so it needs a Chromium-based browser. On a Firefox-only machine Omarchy reports that itself.
- **A Linux app from Meta** would make this redundant. None is announced.
