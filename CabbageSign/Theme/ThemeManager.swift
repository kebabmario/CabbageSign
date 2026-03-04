import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.dark.rawValue
        self.currentTheme = AppTheme(rawValue: saved) ?? .dark
    }
}
