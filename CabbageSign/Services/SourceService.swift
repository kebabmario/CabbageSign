import Foundation

class SourceService: ObservableObject {
    @Published var sources: [AppSource] = [] {
        didSet { saveSources() }
    }

    private let storageKey = "appSources"

    init() {
        loadSources()
    }

    func addSource(_ source: AppSource) {
        sources.append(source)
    }

    func removeSource(at offsets: IndexSet) {
        sources.remove(atOffsets: offsets)
    }

    func fetchApps(from source: AppSource) async throws -> [AppEntry] {
        guard let url = URL(string: source.url) else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)

        // Try AltStore/SideStore repo format first (object with "apps" key)
        if let repoResponse = try? JSONDecoder().decode(RepoResponse.self, from: data) {
            return repoResponse.apps.map { $0.toAppEntry() }
        }

        // Fall back to plain array format
        return (try? JSONDecoder().decode([AppEntry].self, from: data)) ?? []
    }

    private func saveSources() {
        if let data = try? JSONEncoder().encode(sources) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSources() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([AppSource].self, from: data) else { return }
        sources = saved
    }
}

// MARK: - AltStore/SideStore repo format

private struct RepoResponse: Decodable {
    var apps: [RepoApp]
}

private struct RepoApp: Decodable {
    var name: String
    var bundleIdentifier: String
    var version: String
    var developerName: String?
    var developer: String?
    var localizedDescription: String?
    var description: String?
    var iconURL: String?
    var downloadURL: String
    var size: Int?
    var screenshotURLs: [String]?
    var subtitle: String?
    var tagline: String?

    func toAppEntry() -> AppEntry {
        AppEntry(
            name: name,
            bundleIdentifier: bundleIdentifier,
            version: version,
            developer: developerName ?? developer ?? "",
            description: localizedDescription ?? description ?? "",
            iconURL: iconURL,
            downloadURL: downloadURL,
            size: size,
            date: nil,
            screenshotURLs: screenshotURLs ?? [],
            tagline: subtitle ?? tagline ?? ""
        )
    }
}
