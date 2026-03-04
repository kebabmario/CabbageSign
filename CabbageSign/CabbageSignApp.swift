import SwiftUI

@main
struct CabbageSignApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }
}
