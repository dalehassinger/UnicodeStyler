// Unicode Styler — a menu bar clone of YayText "Bold / Italic".
// Converts plain text into Unicode Mathematical Alphanumeric characters
// that keep their bold/italic look when pasted anywhere.
//
// Build: ./build.sh            (creates build/Unicode Styler.app)
//        ./build.sh --install  (also copies it to /Applications and launches it)
// Requires macOS 13+ and Xcode or the Command Line Tools (xcode-select --install).

import SwiftUI
import AppKit
import ServiceManagement

// MARK: - Character mapping

enum Base: Hashable {
    case plain, bold, italic, boldItalic, sansBold, sansItalic, sansBoldItalic
}

struct BaseMap {
    let upper: UInt32          // code point for "A"
    let lower: UInt32          // code point for "a"
    let digit: UInt32?         // code point for "0" (nil = style has no digits)
    var exceptions: [UInt32: UInt32] = [:]
}

let baseMaps: [Base: BaseMap] = [
    .bold:           BaseMap(upper: 0x1D400, lower: 0x1D41A, digit: 0x1D7CE),
    .italic:         BaseMap(upper: 0x1D434, lower: 0x1D44E, digit: nil,
                             exceptions: [0x68: 0x210E]),   // italic "h" lives at U+210E
    .boldItalic:     BaseMap(upper: 0x1D468, lower: 0x1D482, digit: nil),
    .sansBold:       BaseMap(upper: 0x1D5D4, lower: 0x1D5EE, digit: 0x1D7EC),
    .sansItalic:     BaseMap(upper: 0x1D608, lower: 0x1D622, digit: nil),
    .sansBoldItalic: BaseMap(upper: 0x1D63C, lower: 0x1D656, digit: nil),
]

struct OutputStyle: Identifiable {
    let id: String
    let label: String
    let cycle: [Base]          // base styles applied letter by letter, in rotation
}

let outputStyles: [OutputStyle] = [
    OutputStyle(id: "bold",       label: "Bold (serif)",               cycle: [.bold]),
    OutputStyle(id: "italic",     label: "Italic (serif)",             cycle: [.italic]),
    OutputStyle(id: "boldItalic", label: "Bold / italic (serif)",      cycle: [.boldItalic]),
    OutputStyle(id: "sansBold",   label: "Bold (sans)",                cycle: [.sansBold]),
    OutputStyle(id: "sansItalic", label: "Italic (sans)",              cycle: [.sansItalic]),
    OutputStyle(id: "sansBI",     label: "Bold / italic (sans)",       cycle: [.sansBoldItalic]),
    OutputStyle(id: "altBold",    label: "Alternating Bold",           cycle: [.bold, .plain]),
    OutputStyle(id: "altItalic",  label: "Alternating Italic",         cycle: [.italic, .plain]),
    OutputStyle(id: "boldAltIt",  label: "Bold w/ Alternating Italic", cycle: [.bold, .boldItalic]),
    OutputStyle(id: "switchSerif",label: "Italic Switch Serifs",       cycle: [.italic, .sansItalic]),
]

func isAsciiAlphanumeric(_ v: UInt32) -> Bool {
    (48...57).contains(v) || (65...90).contains(v) || (97...122).contains(v)
}

func convert(_ scalar: Unicode.Scalar, to base: Base) -> Unicode.Scalar {
    guard base != .plain, let map = baseMaps[base] else { return scalar }
    let v = scalar.value
    var mapped: UInt32?
    if let e = map.exceptions[v] {
        mapped = e
    } else if (65...90).contains(v) {
        mapped = map.upper + (v - 65)
    } else if (97...122).contains(v) {
        mapped = map.lower + (v - 97)
    } else if (48...57).contains(v), let d = map.digit {
        mapped = d + (v - 48)
    }
    if let m = mapped, let out = Unicode.Scalar(m) { return out }
    return scalar
}

func stylize(_ text: String, cycle: [Base]) -> String {
    var out = String.UnicodeScalarView()
    var i = 0   // counts letters/digits only, so spaces don't break alternation
    for scalar in text.unicodeScalars {
        if isAsciiAlphanumeric(scalar.value) {
            out.append(convert(scalar, to: cycle[i % cycle.count]))
            i += 1
        } else {
            out.append(scalar)
        }
    }
    return String(out)
}

// MARK: - Settings

enum ThemeChoice: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: String { rawValue }

    /// nil = follow macOS; otherwise force Aqua / Dark Aqua for the whole app.
    var appearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light:  return NSAppearance(named: .aqua)
        case .dark:   return NSAppearance(named: .darkAqua)
        }
    }
}

// MARK: - Model

// App state lives in an ObservableObject (Combine) rather than SwiftUI's @State.
// On newer SDKs @State is a macro whose plugin ships only with full Xcode, so this
// keeps the app buildable with just the Command Line Tools.
final class StylerModel: ObservableObject {
    @Published var input = ""
    @Published var copiedID: String?
    @Published var showSettings = false

    @Published var theme: ThemeChoice {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
            applyTheme()
        }
    }

    // Login-item state is owned by macOS (System Settings > General > Login Items),
    // so it is read back from SMAppService rather than stored in UserDefaults.
    @Published private(set) var launchAtLogin = false
    @Published private(set) var loginMessage: String?

    init() {
        let saved = UserDefaults.standard.string(forKey: "theme") ?? ""
        theme = ThemeChoice(rawValue: saved) ?? .system
        refreshLoginStatus()
    }

    func applyTheme() {
        NSApp?.appearance = theme.appearance
    }

    func refreshLoginStatus() {
        switch SMAppService.mainApp.status {
        case .enabled:
            launchAtLogin = true
            loginMessage = nil
        case .requiresApproval:
            launchAtLogin = false
            loginMessage = "Approve Unicode Styler in System Settings › Login Items."
        default:
            launchAtLogin = false
            loginMessage = nil
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            loginMessage = "Couldn't change login item: \(error.localizedDescription)"
        }
        refreshLoginStatus()
    }
}

let sharedModel = StylerModel()

// MARK: - UI

struct ContentView: View {
    @ObservedObject var model: StylerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Unicode Styler").font(.headline)
                Spacer()
                if !model.showSettings {
                    Button("Paste") {
                        if let s = NSPasteboard.general.string(forType: .string) { model.input = s }
                    }
                    Button("Clear") { model.input = "" }
                }
                Button {
                    model.showSettings.toggle()
                    if model.showSettings { model.refreshLoginStatus() }
                } label: {
                    Image(systemName: model.showSettings ? "xmark.circle" : "gearshape")
                }
                .help(model.showSettings ? "Close settings" : "Settings")
            }

            // The styler stays in the layout (just hidden) while Settings is open,
            // so the window keeps the same height and doesn't jump.
            ZStack(alignment: .top) {
                stylerPanel
                    .opacity(model.showSettings ? 0 : 1)
                    .allowsHitTesting(!model.showSettings)
                if model.showSettings {
                    settingsPanel
                }
            }

            Divider()
            HStack {
                Text(model.showSettings ? "Settings are saved automatically" : "Click a style to copy it")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(14)
        .frame(width: 420)
        .onAppear { model.applyTheme() }
    }

    // MARK: Styler

    private var stylerPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $model.input)
                .font(.system(size: 14))
                .frame(height: 70)
                .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.35)))

            // All 10 styles shown at once, no scrolling. Each row is one line,
            // so the window height stays fixed however long the text is.
            VStack(spacing: 6) {
                ForEach(outputStyles) { style in
                    row(for: style)
                }
            }
        }
    }

    @ViewBuilder
    private func row(for style: OutputStyle) -> some View {
        let preview = stylize(model.input.isEmpty ? "Your text here" : model.input, cycle: style.cycle)
        let isCopied = model.copiedID == style.id
        Button {
            copy(preview, id: style.id)
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(style.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(preview)
                        .font(.system(size: 15))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(isCopied ? Color.green : Color.secondary)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.08)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(preview)   // hover to see the full text when a long line is truncated
        .disabled(model.input.isEmpty)
    }

    private func copy(_ text: String, id: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        model.copiedID = id
        let m = model
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if m.copiedID == id { m.copiedID = nil }
        }
    }

    // MARK: Settings

    private var settingsPanel: some View {
        let m = model
        let loginBinding = Binding<Bool>(
            get: { m.launchAtLogin },
            set: { m.setLaunchAtLogin($0) }
        )

        return VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Appearance").font(.subheadline).bold()
                Picker("Theme", selection: $model.theme) {
                    ForEach(ThemeChoice.allCases) { choice in
                        Text(choice.rawValue).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Startup").font(.subheadline).bold()
                Toggle("Start Unicode Styler at login", isOn: loginBinding)
                    .toggleStyle(.switch)

                if let msg = model.loginMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Button("Open Login Items…") {
                        SMAppService.openSystemSettingsLoginItems()
                    }
                    .font(.caption)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
}

// MARK: - App

@main
struct UnicodeStylerApp: App {
    init() {
        // Apply the saved theme as soon as the app launches.
        DispatchQueue.main.async { sharedModel.applyTheme() }
    }

    var body: some Scene {
        MenuBarExtra("Unicode Styler", systemImage: "bold.italic.underline") {
            ContentView(model: sharedModel)
        }
        .menuBarExtraStyle(.window)
    }
}
