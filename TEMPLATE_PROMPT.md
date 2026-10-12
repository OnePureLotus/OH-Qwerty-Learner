# ArkWeb Template — AI / Developer Prompt

Use this repository as a **HarmonyOS ArkWeb app template**. Do not treat `main` as a product branch.

## Core requirements

1. **Template repo** — `main` is the official template (default: Baidu Search demo). Customize on a separate branch, not on `main`.

2. **Follow README** — Read `README.md` first. Respect its setup steps, platform constraints (especially 2in1 zoom limits, signing, white-screen rules), and API 24 requirements.

3. **Branch workflow** — Commit all app-specific work to this repo on branch `app/<app-name>` (e.g. `app/feishu`, `app/bilibili`). Use English [Conventional Commits](https://www.conventionalcommits.org/).

4. **Branch README** — For any distributable `app/*` branch, update `README.md` at the **top** with:
   - App display name
   - Bundle name (`bundleName`) — use format `com.arkwebapp.<app-name>` (e.g. `com.arkwebapp.github`, `com.arkwebapp.baidu`)
   - Default URL (`DEFAULT_URL`)
   - One-line description of what the app loads

5. **Naming** — Framework title is **ArkWeb 框架** (not "Bowen ArkWeb"). Package prefix is `com.arkwebapp.*` (not `com.bowenapp.*`).

## Typical changes per app

- `entry/src/main/ets/pages/Index.ets` — `DEFAULT_URL`, UA if needed
- `AppScope/app.json5` — `bundleName`, version
- `AppScope/resources/base/element/string.json` — `app_name`
- `entry/src/main/resources/base/element/string.json` — `EntryAbility_label`
- `entry/src/main/ets/entryability/EntryAbility.ets` — `APP_TITLE` (2in1 window title)
- Icons under `entry/src/main/resources/base/media/` and `AppScope/resources/base/media/` (see **Icon rules** below)
- Reconfigure signing in DevEco Studio after changing `bundleName` (see **Signing rules** below; do not commit local signing paths)

## Icon rules (required for every `app/*` branch)

Validated reference: branch `app/github` (GitHub app).

### Source vs runtime

| Role | File | Format |
| --- | --- | --- |
| Design master | `entry/.../media/<app-name>.svg` | SVG (vector, kept in repo) |
| Desktop foreground | `foreground.png`, `app_foreground.png` | PNG (exported from SVG) |
| Desktop background | `background.png`, `app_background.png` | PNG, fully transparent |
| Splash / launch | `start_icon.png` | PNG (exported from SVG) |

HarmonyOS `layered-image` and `startWindowIcon` **do not accept SVG at runtime**. Using `.svg` for `foreground` or `start_icon` produces a **puzzle-piece placeholder** on the desktop.

### Canvas sizes (match `main` Baidu template)

| Asset | Canvas | Logo fill |
| --- | --- | --- |
| `foreground.png` / `app_foreground.png` | **512 × 512** | **100%** (full canvas) |
| `background.png` / `app_background.png` | **512 × 512** | fully transparent |
| `start_icon.png` | **256 × 256** | **100%** (full canvas) |

### Export procedure (mandatory)

1. Obtain the official logo as **SVG** → save as `<app-name>.svg`.
2. **Crop** transparent margins from the artwork.
3. **Scale** the cropped logo to **fill the entire target canvas** (do not leave large empty padding — icons will look too small on desktop and splash).
4. Export the three runtime PNGs listed above.
5. Leave `layered_image.json` / `app_layered_image.json` unchanged (they reference `$media:foreground` + `$media:background`).

### Do NOT

- Put brand-color fills in `background.png` / `app_background.png` (system provides the icon plate).
- Use SVG directly for `foreground`, `app_foreground`, or `start_icon`.
- Export logos at ~30–60% canvas size (too small on device; validated fix is **full-canvas fill** like `main`).
- Forget `start_icon.png` (splash will still show the template default).
- Delete `<app-name>.svg` after export (needed for future re-exports).

## Signing rules (common pitfall after `bundleName` change)

1. In DevEco Studio: **File → Project Structure → Signing Configs** → enable **Automatically generate signature** for the new `bundleName`.
2. For **local install / debug**, ensure `build-profile.json5` → `products` → `default` includes `"signingConfig": "default"` and a valid local `signingConfigs` entry. Without this, the build outputs `entry-default-unsigned.hap` and install fails with `code:9568320 / no signature file`.
3. Never commit local certificate paths or passwords from `signingConfigs` to the repo.

## Release builds (unsigned HAP — intentional)

This is an **open-source template**. Official GitHub Releases ship **unsigned** HAP packages so end users sign with their own certificates in DevEco Studio.

### Policy

- **Do** publish `entry-default-unsigned.hap` (or a renamed copy) to GitHub Releases.
- **Do not** commit `signingConfigs` material (`.p12`, `.p7b`, `.cer`, passwords) to the repo.
- **Do not** upload signed HAP to Releases — users must self-sign before installing on device.
- Keep `build-profile.json5` in git with `signingConfigs: []` (or omit `signingConfig` on `products.default`).

### CLI build (unsigned release)

DevEco toolchain (example paths on Windows):

```bat
set JAVA_HOME=C:\Program Files\Huawei\DevEco Studio\jbr
set DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk
set NODE_HOME=C:\Program Files\Huawei\DevEco Studio\tools\node

tools\ohpm\bin\ohpm.bat install --all
tools\hvigor\bin\hvigorw.bat assembleHap -p product=default -p buildMode=release --no-daemon
```

Output: `entry/build/default/outputs/default/entry-default-unsigned.hap`

### Release per branch

For each distributable branch (`main` or `app/*`):

1. Check out the branch and read `versionName` / `bundleName` from `AppScope/app.json5`.
2. Build unsigned release HAP as above.
3. Rename artifact for clarity, e.g. `arkweb-github-v8.4.3-unsigned.hap`.
4. Create a GitHub Release **on that branch** (`gh release create … --target <branch>`), attach the unsigned HAP, and note in release notes that users must sign locally before install.

### User install flow (release HAP)

1. Download unsigned HAP from GitHub Releases.
2. Open project in DevEco Studio (or import HAP signing flow).
3. Configure **Signing Configs** for their `bundleName`.
4. Sign the HAP (or rebuild signed from source) and install on device.
