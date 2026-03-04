import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            SignView()
                .tabItem {
                    Label("Sign", systemImage: "signature")
                }
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(themeManager.currentTheme.accentColor)
        .background(themeManager.currentTheme.backgroundColor)
    }
}
