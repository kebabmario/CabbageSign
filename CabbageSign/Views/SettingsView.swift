import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var githubService = GitHubActionsService.shared

    @State private var tokenInput: String = ""
    @State private var showToken: Bool = false

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                List {
                    themeSection
                    githubSection
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            tokenInput = GitHubActionsService.shared.githubToken
        }
    }

    private var themeSection: some View {
        Section {
            ForEach(AppTheme.allCases) { theme in
                Button(action: { themeManager.currentTheme = theme }) {
                    HStack {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 20, height: 20)
                        Text(theme.rawValue)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        Spacer()
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardColor)
            }
        } header: {
            Text("Theme")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
    }

    private var githubSection: some View {
        Section {
            HStack {
                Text("Token")
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
                if showToken {
                    TextField("GitHub Token", text: $tokenInput, onCommit: {
                        GitHubActionsService.shared.githubToken = tokenInput
                    })
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                } else {
                    SecureField("GitHub Token", text: $tokenInput, onCommit: {
                        GitHubActionsService.shared.githubToken = tokenInput
                    })
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                }
                Button(action: { showToken.toggle() }) {
                    Image(systemName: showToken ? "eye.slash" : "eye")
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
            }
            .listRowBackground(themeManager.currentTheme.cardColor)

            HStack {
                Text("Repository")
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
                TextField("owner/repo", text: $githubService.repository)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .listRowBackground(themeManager.currentTheme.cardColor)

            HStack {
                Text("Workflow File")
                    .foregroundColor(themeManager.currentTheme.textColor)
                Spacer()
                TextField("sign.yml", text: $githubService.workflowFilename)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .listRowBackground(themeManager.currentTheme.cardColor)
        } header: {
            Text("GitHub Configuration")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        } footer: {
            Text("Your GitHub token is stored securely in the Keychain.")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(12)
                VStack(alignment: .leading) {
                    Text("CabbageSign")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
            }
            .listRowBackground(themeManager.currentTheme.cardColor)
        } header: {
            Text("About")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
    }
}
