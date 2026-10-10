# Unicode Styler

A small macOS menu bar app that turns plain text into **Unicode bold, italic and sans-serif styles** you can paste anywhere: LinkedIn, X/Twitter, Facebook, Slack, Teams, email and so on.

It's a local, offline take on web tools like YayText. No browser, no ads, no tracking. Type your text, click a style, paste.

```
Bold (serif)          𝐇𝐞𝐥𝐥𝐨 𝐯𝐂𝐑𝐎𝐂𝐒 𝟐𝟎𝟐𝟔
Italic (serif)        𝐻𝑒𝑙𝑙𝑜 𝑣𝐶𝑅𝑂𝐶𝑆 2026
Bold / italic (serif) 𝑯𝒆𝒍𝒍𝒐 𝒗𝑪𝑹𝑶𝑪𝑺 2026
Bold (sans)           𝗛𝗲𝗹𝗹𝗼 𝘃𝗖𝗥𝗢𝗖𝗦 𝟮𝟬𝟮𝟲
Italic (sans)         𝘏𝘦𝘭𝘭𝘰 𝘷𝘊𝘙𝘖𝘊𝘚 2026
Bold / italic (sans)  𝙃𝙚𝙡𝙡𝙤 𝙫𝘾𝙍𝙊𝘾𝙎 2026
Alternating Bold      𝐇e𝐥l𝐨 v𝐂R𝐎C𝐒 2𝟎2𝟔
Alternating Italic    𝐻e𝑙l𝑜 v𝐶R𝑂C𝑆 2026
Bold w/ Alt Italic    𝐇𝒆𝐥𝒍𝐨 𝒗𝐂𝑹𝐎𝑪𝐒 2𝟎2𝟔
Italic Switch Serifs  𝐻𝘦𝑙𝘭𝑜 𝘷𝐶𝘙𝑂𝘊𝑆 2026
```

## Features

- Lives in the menu bar, with no Dock icon
- Shows all 10 styles at once, with a live preview as you type
- Click any style to copy it, and a checkmark confirms the copy
- **Paste** and **Clear** buttons for quick input
- **Settings** (gear icon):
  - Appearance: System, Light or Dark
  - Start at login, using macOS Login Items
- A single Swift source file with no dependencies and no Xcode project

## Download

**[Download UnicodeStyler.zip](https://github.com/dalehassinger/UnicodeStyler/releases/latest/download/UnicodeStyler.zip)** (universal, Apple silicon and Intel), or see the [project page](https://dalehassinger.github.io/UnicodeStyler).

Unzip it, drag **Unicode Styler** to Applications and open it. The app isn't signed with an Apple Developer ID yet, so macOS warns you the first time. Click **Done**, then go to **System Settings › Privacy & Security** and click **Open Anyway**. Or run:

```bash
xattr -dr com.apple.quarantine "/Applications/Unicode Styler.app"
```

## Requirements

- macOS 13 Ventura or later
- Xcode, or just the Command Line Tools:

  ```bash
  xcode-select --install
  ```

## Build and install

```bash
git clone <this repo>
cd UnicodeStyler
chmod +x build.sh
./build.sh --install
```

| Command | What it does |
|---|---|
| `./build.sh` | Builds `build/Unicode Styler.app` |
| `./build.sh --install` | Builds, copies to `/Applications` and launches it |
| `./build.sh --release` | Builds and zips it to `build/UnicodeStyler.zip` for GitHub Releases |

The script compiles a universal binary (Apple silicon and Intel) with `swiftc` and `lipo`, creates the `.app` bundle and `Info.plist`, and ad-hoc signs the app so it runs locally. If full Xcode is installed, it uses Xcode's toolchain automatically.

Look for the **B/I/U** icon in the menu bar after launch.

## Usage

1. Click the menu bar icon.
2. Type or paste your text.
3. Click a style to copy it to the clipboard.
4. Paste it wherever you like.

Hover over a row to see the full styled text when a long line is cut off. Clicking always copies the complete text.

### Start at login

Open **Settings → Start Unicode Styler at login**. macOS may ask you to approve it. If so, use the **Open Login Items…** button that appears. This works best when the app is in `/Applications`, which `--install` handles for you.

## How it works

The styled text isn't formatting, it's different characters. Unicode's **Mathematical Alphanumeric Symbols** block (U+1D400–U+1D7FF) contains full A–Z and a–z alphabets in bold, italic, sans-serif and other styles, each starting at a fixed code point:

| Style | `A` | `a` | `0` |
|---|---|---|---|
| Bold | U+1D400 | U+1D41A | U+1D7CE |
| Italic | U+1D434 | U+1D44E | — |
| Bold italic | U+1D468 | U+1D482 | — |
| Sans bold | U+1D5D4 | U+1D5EE | U+1D7EC |
| Sans italic | U+1D608 | U+1D622 | — |
| Sans bold italic | U+1D63C | U+1D656 | — |

Each letter is shifted by its position in the alphabet: `start + (letter - 'A')`. There's one quirk: italic small **h** was already in Unicode as the Planck constant `ℎ` (U+210E), so the italic block has a gap there and the app maps it separately. Italic styles have no digits, so numbers stay plain. Punctuation, spaces and emoji pass through unchanged.

The "alternating" styles rotate through two styles one letter at a time, skipping spaces so the pattern stays even.

### Things to keep in mind

- **Accessibility:** Screen readers may read these characters one by one or as math symbols. Use them for emphasis, not for whole posts.
- **Search:** `𝐁𝐨𝐥𝐝` isn't the same text as `Bold`, so styled words may not show up in searches.
- **Fonts:** Rendering depends on the platform. A few older systems may show boxes.

## PowerShell version

`Convert-UnicodeStyle.ps1` does the same conversion from the command line in PowerShell 5.1 or 7:

```powershell
./Convert-UnicodeStyle.ps1 "Hello vCROCS"                         # all styles
./Convert-UnicodeStyle.ps1 "Hello vCROCS" -Style SansBold -Copy   # one style to the clipboard
```

## Publishing a release

```bash
./build.sh --release
gh release create v1.1 build/UnicodeStyler.zip --title "Unicode Styler 1.1"
```

The landing page in `docs/` is served by GitHub Pages (Settings › Pages › Deploy from branch `main`, folder `/docs`).

## Project files

```
UnicodeStyler/
├── UnicodeStyler.swift        # the whole app: mapping, UI, settings
├── build.sh                   # build / install / release script
├── Convert-UnicodeStyle.ps1   # PowerShell version
├── docs/index.html            # landing page (GitHub Pages)
├── .gitignore
└── README.md
```

## Author

**Dale Hassinger**, [vCROCS.info](https://www.vcrocs.info)
