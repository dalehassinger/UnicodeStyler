# Unicode Styler

Turn plain text into **Unicode bold, italic and sans-serif styles** you can paste anywhere: LinkedIn, X, Facebook, Bluesky, Slack, Teams, email and so on. LinkedIn and most social sites don't have a bold button. These characters keep their style wherever you paste them.

It's a local, offline take on web tools like YayText. No ads and no tracking. Type your text, click a style, paste.

| | |
|---|---|
| 🌐 **Project page** | [dalehassinger.github.io/UnicodeStyler](https://dalehassinger.github.io/UnicodeStyler) |
| 🍎 **Mac app** | [Download UnicodeStyler.zip](https://github.com/dalehassinger/UnicodeStyler/releases/latest/download/UnicodeStyler.zip) (macOS 13+, Apple silicon and Intel) |
| 🪟🐧 **Windows and Linux** | [Open the web version](https://dalehassinger.github.io/UnicodeStyler/app/), then bookmark it or install it from Edge or Chrome |
| 💻 **Command line** | [`Convert-UnicodeStyle.ps1`](Convert-UnicodeStyle.ps1) for PowerShell 5.1 or 7 |

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

You can try every style in your browser on the [project page](https://dalehassinger.github.io/UnicodeStyler) before downloading anything.

---

## Mac app

A menu bar app with no Dock icon. Click the **B/I/U** icon, type, and click a style.

### Features

- All 10 styles shown at once, with a live preview as you type and no scrolling
- Click any style to copy it, and a checkmark confirms the copy
- **Paste** and **Clear** buttons for quick input
- Long text is shortened on screen with the full text on hover. Clicking always copies the full text.
- **Settings** (gear icon):
  - Appearance: System, Light or Dark
  - Start at login, using macOS Login Items
- Works offline and makes no network connections
- A single Swift source file with no dependencies and no Xcode project

### Install

1. [Download UnicodeStyler.zip](https://github.com/dalehassinger/UnicodeStyler/releases/latest/download/UnicodeStyler.zip). It's a universal app for Apple silicon and Intel and needs macOS 13 Ventura or later.
2. Double-click the zip and drag **Unicode Styler** into Applications.
3. Open it. The app isn't signed with an Apple Developer ID yet, so macOS warns you the first time. It isn't damaged. Click **Done**, go to **System Settings › Privacy & Security**, and click **Open Anyway**. Or run:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/Unicode Styler.app"
   ```

4. Look for the **B/I/U** icon in your menu bar.

### Start at login

Open **Settings → Start Unicode Styler at login**. macOS may ask you to approve it. If so, use the **Open Login Items…** button that appears. This works best when the app is in `/Applications`.

---

## Web version for Windows and Linux

**[dalehassinger.github.io/UnicodeStyler/app/](https://dalehassinger.github.io/UnicodeStyler/app/)**

No Mac? The web version runs in any modern browser on Windows, Linux or ChromeOS. It has the same 10 styles as the Mac app and uses the same character mapping, so the text you copy is identical. There's nothing to install.

### Features

- All 10 styles with a live preview and click to copy
- Keyboard shortcuts: **Alt + 1** to **Alt + 0** copies a style
- **Paste** and **Clear** buttons and a character count
- **Settings** (gear icon):
  - Appearance: System, Light or Dark
  - Remember my text between visits (off by default)
- Works offline after your first visit
- Private: everything runs in your browser, and your text is never sent anywhere

### Keep it one click away

1. Open the [web version](https://dalehassinger.github.io/UnicodeStyler/app/) in Edge, Chrome, Firefox or any modern browser.
2. Bookmark it with **Ctrl + D**, or drag the address to your bookmarks bar.
3. Optional: in Edge or Chrome, click **Install** in the address bar. It opens in its own window, and you can pin it to the taskbar or Start menu.

---

## PowerShell version

`Convert-UnicodeStyle.ps1` does the same conversion from the command line in PowerShell 5.1 or 7 on Windows, macOS or Linux:

```powershell
./Convert-UnicodeStyle.ps1 "Hello vCROCS"                         # all styles
./Convert-UnicodeStyle.ps1 "Hello vCROCS" -Style SansBold -Copy   # one style to the clipboard
```

Styles: `Bold`, `Italic`, `BoldItalic`, `SansBold`, `SansItalic`, `SansBoldItalic`, `AltBold`, `AltItalic`, `BoldAltItalic`, `ItalicSwitchSerif`.

---

## Tips for LinkedIn

- **Style the hook.** LinkedIn shows two or three lines before **…see more**. Make the first line bold and leave the rest plain.
- **Bold (sans) matches LinkedIn's font** better than the serif styles.
- **Style short section labels**, not whole paragraphs. A full post in bold is hard to read.
- **Skip hashtags.** `#𝘃𝗘𝘅𝗽𝗲𝗿𝘁` is a different hashtag from `#vExpert`, so nobody will find it.
- **Keep names and product names plain** if you want the post to show up in search.

---

## How it works

The styled text isn't formatting. These are different characters. Unicode's **Mathematical Alphanumeric Symbols** block (U+1D400–U+1D7FF) contains full A–Z and a–z alphabets in bold, italic, sans-serif and other styles, each starting at a fixed code point:

| Style | `A` | `a` | `0` |
|---|---|---|---|
| Bold | U+1D400 | U+1D41A | U+1D7CE |
| Italic | U+1D434 | U+1D44E | — |
| Bold italic | U+1D468 | U+1D482 | — |
| Sans bold | U+1D5D4 | U+1D5EE | U+1D7EC |
| Sans italic | U+1D608 | U+1D622 | — |
| Sans bold italic | U+1D63C | U+1D656 | — |

Each letter is shifted by its position in the alphabet: `start + (letter - 'A')`.

- **Italic h is somewhere else.** Unicode already had `ℎ` as the Planck constant (U+210E), so the italic block has a gap there and it's mapped separately.
- **Italic styles have no digits**, so numbers stay plain. Bold styles have their own 𝟎 to 𝟗.
- **Everything else passes through.** Punctuation, spaces and emoji are left as they are.
- The **alternating** styles rotate through two styles one letter at a time, skipping spaces so the pattern stays even.

### Things to keep in mind

- **Accessibility:** Screen readers may read these characters one by one or as math symbols. Use them for emphasis, not whole posts.
- **Search:** `𝐁𝐨𝐥𝐝` isn't the same text as `Bold`, so styled words may not show up in searches.
- **Fonts:** Rendering depends on the platform. A few older systems may show boxes.

---

## Privacy

- The Mac app makes no network connections.
- The web version runs entirely in your browser. Your text is only saved, in your own browser, if you turn on **Remember my text**.
- No accounts, analytics or tracking in either one.
- The clipboard is only read when you click **Paste**, and only written when you click a style.

---

## Build the Mac app from source

Requirements: macOS 13 or later, and Xcode or just the Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/dalehassinger/UnicodeStyler.git
cd UnicodeStyler
chmod +x build.sh
./build.sh --install
```

| Command | What it does |
|---|---|
| `./build.sh` | Builds `build/Unicode Styler.app` |
| `./build.sh --install` | Builds, copies to `/Applications` and launches it |
| `./build.sh --release` | Builds and zips it to `build/UnicodeStyler.zip` for GitHub Releases |

The script compiles a universal binary (Apple silicon and Intel) with `swiftc` and `lipo`, creates the `.app` bundle and `Info.plist`, and ad-hoc signs it. If full Xcode is installed, it uses Xcode's toolchain automatically. The app avoids SwiftUI's `@State` macro, so it builds with just the Command Line Tools.

---

## Publishing

**Release the Mac app:**

```bash
./build.sh --release
gh release create v1.1 build/UnicodeStyler.zip --title "Unicode Styler 1.1"
```

The download links always point to `releases/latest/download/UnicodeStyler.zip`, so a new release updates every link automatically.

**Websites:** Everything in `docs/` is served by GitHub Pages (**Settings › Pages › Deploy from a branch**, `main`, folder `/docs`):

| Page | URL |
|---|---|
| Landing page with live demo | [dalehassinger.github.io/UnicodeStyler](https://dalehassinger.github.io/UnicodeStyler) |
| Web version for Windows and Linux | [dalehassinger.github.io/UnicodeStyler/app/](https://dalehassinger.github.io/UnicodeStyler/app/) |

When you change `docs/app/index.html`, bump `CACHE` in `docs/app/sw.js` (for example `unicode-styler-web-v2`) so installed copies pick up the new version.

---

## Release notes

### v1.1

- New: Settings panel with Light, Dark and System appearance
- New: Start at login, using macOS Login Items
- New: Web version for Windows and Linux that you can bookmark or install from Edge or Chrome
- Improved: All 10 styles shown at once, with no scrolling
- Improved: Universal build for Apple silicon and Intel
- Fixed: Builds with only the Command Line Tools, no full Xcode needed

### v1.0

- First release: menu bar app with 10 styles, live preview and click to copy

---

## Project files

```
UnicodeStyler/
├── UnicodeStyler.swift          # the Mac app: mapping, UI, settings
├── build.sh                     # build / install / release script
├── Convert-UnicodeStyle.ps1     # PowerShell version
├── docs/
│   ├── index.html               # landing page with live demo (GitHub Pages)
│   └── app/
│       ├── index.html           # web version for Windows and Linux
│       ├── manifest.webmanifest # lets Edge and Chrome install it as an app
│       ├── sw.js                # offline support
│       └── icon-*.png           # app icons
├── LICENSE                      # MIT
├── .gitignore
└── README.md
```

---

## Credits

Inspired by [YayText](https://yaytext.com/bold-italic/), which does this well on the web.

## Author

**Dale Hassinger**, [vCROCS.info](https://www.vcrocs.info). More free tools, PowerShell automation and VMware Cloud Foundation guides.

## License

[MIT](LICENSE)
