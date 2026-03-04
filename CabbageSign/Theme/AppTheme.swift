import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Light"
    case green = "Green"
    case purple = "Purple"
    case blue = "Blue"
    case orange = "Orange"
    case pink = "Pink"
    case red = "Red"
    case cyberpunk = "Cyberpunk"
    case nord = "Nord"
    case solarized = "Solarized"
    case dracula = "Dracula"
    case monokai = "Monokai"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light, .solarized:
            return .light
        case .dark, .green, .purple, .blue, .orange, .pink, .red,
             .cyberpunk, .nord, .dracula, .monokai:
            return .dark
        }
    }

    var backgroundColor: Color {
        switch self {
        case .dark: return Color.black
        case .light: return Color(UIColor.systemBackground)
        case .green: return Color(hex: "#0D1F0D")
        case .purple: return Color(hex: "#1A001A")
        case .blue: return Color(hex: "#001A2C")
        case .orange: return Color(hex: "#1A0D00")
        case .pink: return Color(hex: "#1A0010")
        case .red: return Color(hex: "#1A0000")
        case .cyberpunk: return Color.black
        case .nord: return Color(hex: "#2E3440")
        case .solarized: return Color(hex: "#FDF6E3")
        case .dracula: return Color(hex: "#282A36")
        case .monokai: return Color(hex: "#272822")
        }
    }

    var accentColor: Color {
        switch self {
        case .dark: return Color.blue
        case .light: return Color.blue
        case .green: return Color(hex: "#4CAF50")
        case .purple: return Color(hex: "#9C27B0")
        case .blue: return Color(hex: "#2196F3")
        case .orange: return Color(hex: "#FF9800")
        case .pink: return Color(hex: "#E91E63")
        case .red: return Color(hex: "#F44336")
        case .cyberpunk: return Color(hex: "#00FF41")
        case .nord: return Color(hex: "#88C0D0")
        case .solarized: return Color(hex: "#268BD2")
        case .dracula: return Color(hex: "#BD93F9")
        case .monokai: return Color(hex: "#A6E22E")
        }
    }

    var cardColor: Color {
        switch self {
        case .dark: return Color(UIColor.systemGray6)
        case .light: return Color(UIColor.secondarySystemBackground)
        case .green: return Color(hex: "#1C2E1C")
        case .purple: return Color(hex: "#2A0A2A")
        case .blue: return Color(hex: "#0A2A3C")
        case .orange: return Color(hex: "#2A1A00")
        case .pink: return Color(hex: "#2A001A")
        case .red: return Color(hex: "#2A0000")
        case .cyberpunk: return Color(hex: "#0A0A0A")
        case .nord: return Color(hex: "#3B4252")
        case .solarized: return Color(hex: "#EEE8D5")
        case .dracula: return Color(hex: "#44475A")
        case .monokai: return Color(hex: "#3E3D32")
        }
    }

    var textColor: Color {
        switch self {
        case .light, .solarized: return Color.primary
        default: return Color.white
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .light, .solarized: return Color.secondary
        default: return Color.gray
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
