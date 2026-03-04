import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var githubService = GitHubActionsService.shared
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var tokenInput: String = ""
    @State private var showToken: Bool = false
    @State private var savedFeedback: Bool = false
    @State private var feedbackTask: Task<Void, Never>?

    var isIpad: Bool { horizontalSizeClass == .regular }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        NavigationStack {
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
        .onDisappear {
            persistToken()
        }
    }

    private func persistToken() {
        GitHubActionsService.shared.githubToken = tokenInput
    }

    private func saveSettings() {
        persistToken()
        feedbackTask?.cancel()
        savedFeedback = true
        feedbackTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if !Task.isCancelled {
                savedFeedback = false
            }
        }
    }

    private var themeSection: some View {
        Section {
            ForEach(AppTheme.allCases) { theme in
                Button(action: { themeManager.currentTheme = theme }) {
                    HStack {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: isIpad ? 26 : 20, height: isIpad ? 26 : 20)
                        Text(theme.rawValue)
                            .font(isIpad ? .title3 : .body)
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
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("GitHub Token")
                        .font(isIpad ? .title3 : .body)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Spacer()
                    Button(action: { showToken.toggle() }) {
                        Image(systemName: showToken ? "eye.slash" : "eye")
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    }
                }
                if showToken {
                    TextField("Paste token here", text: $tokenInput)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(isIpad ? .title3 : .body)
                } else {
                    SecureField("Paste token here", text: $tokenInput)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .font(isIpad ? .title3 : .body)
                }
            }
            .listRowBackground(themeManager.currentTheme.cardColor)

            VStack(alignment: .leading, spacing: 6) {
                Text("Repository")
                    .font(isIpad ? .title3 : .body)
                    .foregroundColor(themeManager.currentTheme.textColor)
                TextField("owner/repo", text: $githubService.repository)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(isIpad ? .title3 : .body)
            }
            .listRowBackground(themeManager.currentTheme.cardColor)

            VStack(alignment: .leading, spacing: 6) {
                Text("Workflow File")
                    .font(isIpad ? .title3 : .body)
                    .foregroundColor(themeManager.currentTheme.textColor)
                TextField("sign.yml", text: $githubService.workflowFilename)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(isIpad ? .title3 : .body)
            }
            .listRowBackground(themeManager.currentTheme.cardColor)

            Button(action: saveSettings) {
                HStack {
                    Spacer()
                    if savedFeedback {
                        Label("Saved!", systemImage: "checkmark.circle.fill")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    } else {
                        Text("Save Settings")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(themeManager.currentTheme.accentColor)
        } header: {
            Text("GitHub Configuration")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text("GitHub Token: Create a Personal Access Token (PAT) at https://github.com → Settings → Developer settings → Personal access tokens → Tokens (classic). Enable the workflow scope. Paste the token here.")
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .font(isIpad ? .footnote : .caption)
                Text("Repository: Enter your GitHub repo in owner/repo format (e.g. yourname/CabbageSign).")
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .font(isIpad ? .footnote : .caption)
                Text("Your token is stored securely in the Keychain.")
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .font(isIpad ? .footnote : .caption)
            }
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .resizable()
                    .frame(width: isIpad ? 64 : 50, height: isIpad ? 64 : 50)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                VStack(alignment: .leading) {
                    Text("CabbageSign")
                        .font(isIpad ? .title2 : .headline)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Text("Version \(appVersion)")
                        .font(isIpad ? .subheadline : .caption)
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
