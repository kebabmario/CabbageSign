import SwiftUI
import UniformTypeIdentifiers

struct SignView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var githubService = GitHubActionsService.shared
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var ipaName: String?
    @State private var ipaData: Data?
    @State private var p12Name: String?
    @State private var p12Data: Data?
    @State private var provisionName: String?
    @State private var provisionData: Data?
    @State private var certPassword: String = ""
    @State private var requiresPassword: Bool = false
    @State private var isSigning: Bool = false
    @State private var statusMessage: String = ""
    @State private var errorMessage: String = ""
    @State private var signedArtifactURL: String?
    @State private var showingIPAPicker = false
    @State private var showingP12Picker = false
    @State private var showingProvisionPicker = false
    @State private var progress: Double = 0

    var isIpad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: isIpad ? 24 : 16) {
                        filePickerSection
                        if requiresPassword {
                            passwordSection
                        }
                        if !statusMessage.isEmpty {
                            statusSection
                        }
                        if !errorMessage.isEmpty {
                            errorSection
                        }
                        if let artifactURL = signedArtifactURL {
                            artifactSection(url: artifactURL)
                        }
                        signButton
                    }
                    .padding(isIpad ? 24 : 16)
                }
            }
            .navigationTitle("Sign")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingIPAPicker) {
            DocumentPickerView(contentTypes: [UTType(filenameExtension: "ipa") ?? .data]) { name, data in
                ipaName = name
                ipaData = data
            }
        }
        .sheet(isPresented: $showingP12Picker) {
            DocumentPickerView(contentTypes: [UTType(filenameExtension: "p12") ?? .data]) { name, data in
                p12Name = name
                p12Data = data
                if let data = data {
                    requiresPassword = SigningService.requiresPassword(p12Data: data)
                    if requiresPassword { certPassword = "" }
                }
            }
        }
        .sheet(isPresented: $showingProvisionPicker) {
            DocumentPickerView(contentTypes: [UTType(filenameExtension: "mobileprovision") ?? .data]) { name, data in
                provisionName = name
                provisionData = data
            }
        }
    }

    private var filePickerSection: some View {
        VStack(spacing: 12) {
            FilePickerRow(
                title: "IPA File",
                filename: ipaName,
                icon: "app.badge",
                accentColor: themeManager.currentTheme.accentColor,
                cardColor: themeManager.currentTheme.cardColor,
                textColor: themeManager.currentTheme.textColor,
                secondaryTextColor: themeManager.currentTheme.secondaryTextColor
            ) {
                showingIPAPicker = true
            }

            FilePickerRow(
                title: "P12 Certificate",
                filename: p12Name,
                icon: "lock.shield",
                accentColor: themeManager.currentTheme.accentColor,
                cardColor: themeManager.currentTheme.cardColor,
                textColor: themeManager.currentTheme.textColor,
                secondaryTextColor: themeManager.currentTheme.secondaryTextColor
            ) {
                showingP12Picker = true
            }

            FilePickerRow(
                title: "Mobile Provision",
                filename: provisionName,
                icon: "doc.badge.checkmark",
                accentColor: themeManager.currentTheme.accentColor,
                cardColor: themeManager.currentTheme.cardColor,
                textColor: themeManager.currentTheme.textColor,
                secondaryTextColor: themeManager.currentTheme.secondaryTextColor
            ) {
                showingProvisionPicker = true
            }
        }
    }

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Certificate Password")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.textColor)
            SecureField("Enter password", text: $certPassword)
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                .foregroundColor(themeManager.currentTheme.textColor)
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ProgressView()
                    .tint(themeManager.currentTheme.accentColor)
                Text(statusMessage)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .font(.subheadline)
            }
            ProgressView(value: progress)
                .tint(themeManager.currentTheme.accentColor)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var errorSection: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.subheadline)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private func artifactSection(url: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Signing Complete!")
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .font(.headline)
            }
            if let destination = URL(string: url) {
                Link("Download Signed IPA", destination: destination)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var signButton: some View {
        Button(action: startSigning) {
            HStack {
                if isSigning {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "signature")
                }
                Text(isSigning ? "Signing..." : "Sign IPA")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSign ? themeManager.currentTheme.accentColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(!canSign || isSigning)
    }

    private var canSign: Bool {
        ipaData != nil && p12Data != nil && provisionData != nil &&
        (!requiresPassword || !certPassword.isEmpty)
    }

    private func startSigning() {
        guard let ipaData = ipaData,
              let p12Data = p12Data,
              let provisionData = provisionData else { return }

        isSigning = true
        errorMessage = ""
        statusMessage = "Preparing files..."
        signedArtifactURL = nil
        progress = 0.1

        Task {
            do {
                let p12Base64 = p12Data.base64EncodedString()
                let provisionBase64 = provisionData.base64EncodedString()

                await MainActor.run { statusMessage = "Uploading IPA..."; progress = 0.2 }

                let ipaBase64 = ipaData.base64EncodedString()

                await MainActor.run { statusMessage = "Dispatching workflow..."; progress = 0.3 }

                let runId = try await GitHubActionsService.shared.dispatchWorkflow(
                    ipaBase64: ipaBase64,
                    p12Base64: p12Base64,
                    provisionBase64: provisionBase64,
                    certPassword: certPassword
                )

                await MainActor.run { statusMessage = "Workflow started (Run #\(runId))"; progress = 0.4 }

                let parts = GitHubActionsService.shared.repository.split(separator: "/")
                guard parts.count == 2 else { return }
                let owner = String(parts[0])
                let repo = String(parts[1])

                var completed = false
                while !completed {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    let (status, conclusion) = try await GitHubActionsService.shared.pollRunStatus(owner: owner, repo: repo, runId: runId)

                    await MainActor.run {
                        statusMessage = "Status: \(status)"
                        if status == "in_progress" { progress = 0.7 }
                    }

                    if status == "completed" {
                        completed = true
                        if conclusion == "success" {
                            await MainActor.run { progress = 1.0; statusMessage = "Complete!" }
                            let artifactURL = try await GitHubActionsService.shared.getArtifactURL(owner: owner, repo: repo, runId: runId)
                            await MainActor.run { signedArtifactURL = artifactURL }
                        } else {
                            await MainActor.run { errorMessage = "Workflow failed: \(conclusion ?? "unknown")" }
                        }
                    }
                }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
            await MainActor.run { isSigning = false; if errorMessage.isEmpty { statusMessage = "" } }
        }
    }
}

struct FilePickerRow: View {
    let title: String
    let filename: String?
    let icon: String
    let accentColor: Color
    let cardColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(textColor)
                    Text(filename ?? "Tap to select")
                        .font(.subheadline)
                        .foregroundColor(filename != nil ? accentColor : secondaryTextColor)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(secondaryTextColor)
            }
            .padding()
            .background(cardColor)
            .cornerRadius(12)
        }
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let completion: (String, Data?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (String, Data?) -> Void
        init(completion: @escaping (String, Data?) -> Void) { self.completion = completion }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            let data = try? Data(contentsOf: url)
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
            completion(url.lastPathComponent, data)
        }
    }
}
