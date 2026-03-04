import Foundation
import Security

class GitHubActionsService: ObservableObject {
    static let shared = GitHubActionsService()

    private let keychainKey = "CabbageSign.githubToken"

    var githubToken: String {
        get { KeychainHelper.load(key: keychainKey) ?? "" }
        set { KeychainHelper.save(key: keychainKey, value: newValue) }
    }

    @Published var repository: String {
        didSet { UserDefaults.standard.set(repository, forKey: "githubRepository") }
    }

    @Published var workflowFilename: String {
        didSet { UserDefaults.standard.set(workflowFilename, forKey: "workflowFilename") }
    }

    @Published var branch: String {
        didSet { UserDefaults.standard.set(branch, forKey: "workflowBranch") }
    }

    init() {
        self.repository = UserDefaults.standard.string(forKey: "githubRepository") ?? ""
        self.workflowFilename = UserDefaults.standard.string(forKey: "workflowFilename") ?? "sign.yml"
        self.branch = UserDefaults.standard.string(forKey: "workflowBranch") ?? "main"
    }

    func dispatchWorkflow(ipaBase64: String, p12Base64: String, provisionBase64: String, certPassword: String) async throws -> Int {
        guard !githubToken.isEmpty else { throw GitHubError.missingToken }
        guard !repository.isEmpty else { throw GitHubError.missingRepository }

        let parts = repository.split(separator: "/")
        guard parts.count == 2 else { throw GitHubError.invalidRepository }
        let owner = String(parts[0])
        let repo = String(parts[1])

        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/actions/workflows/\(workflowFilename)/dispatches"
        guard let url = URL(string: urlString) else { throw GitHubError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let body: [String: Any] = [
            "ref": branch,
            "inputs": [
                "ipa_base64": ipaBase64,
                "p12_base64": p12Base64,
                "mobileprovision_base64": provisionBase64,
                "cert_password": certPassword
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...204).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GitHubError.dispatchFailed(statusCode: statusCode, detail: body)
        }

        try await Task.sleep(nanoseconds: 3_000_000_000)
        return try await getLatestRunId(owner: owner, repo: repo)
    }

    private func getLatestRunId(owner: String, repo: String) async throws -> Int {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/actions/workflows/\(workflowFilename)/runs?per_page=1"
        guard let url = URL(string: urlString) else { throw GitHubError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let runs = json?["workflow_runs"] as? [[String: Any]]
        guard let runId = runs?.first?["id"] as? Int else { throw GitHubError.noRunFound }
        return runId
    }

    func pollRunStatus(owner: String, repo: String, runId: Int) async throws -> (status: String, conclusion: String?) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/actions/runs/\(runId)"
        guard let url = URL(string: urlString) else { throw GitHubError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let status = json?["status"] as? String ?? "unknown"
        let conclusion = json?["conclusion"] as? String
        return (status, conclusion)
    }

    func getArtifactURL(owner: String, repo: String, runId: Int) async throws -> String? {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/actions/runs/\(runId)/artifacts"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let artifacts = json?["artifacts"] as? [[String: Any]]
        guard let artifact = artifacts?.first,
              let archiveURL = artifact["archive_download_url"] as? String else { return nil }
        return archiveURL
    }

    enum GitHubError: LocalizedError {
        case missingToken
        case missingRepository
        case invalidRepository
        case invalidURL
        case dispatchFailed(statusCode: Int, detail: String)
        case noRunFound

        var errorDescription: String? {
            switch self {
            case .missingToken: return "GitHub token not configured. Please set it in Settings."
            case .missingRepository: return "Repository not configured. Please set it in Settings."
            case .invalidRepository: return "Repository format should be owner/repo."
            case .invalidURL: return "Invalid URL."
            case .dispatchFailed(let statusCode, let detail):
                if statusCode == 422 {
                    return "Failed to dispatch workflow (HTTP \(statusCode)): branch not found or workflow not enabled. Check the Branch setting matches your repo's default branch."
                }
                return "Failed to dispatch workflow (HTTP \(statusCode))\(detail.isEmpty ? "" : ": \(detail)")"
            case .noRunFound: return "No workflow run found."
            }
        }
    }
}

class KeychainHelper {
    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
