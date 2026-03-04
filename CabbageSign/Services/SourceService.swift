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
        let apps = try JSONDecoder().decode([AppEntry].self, from: data)
        return apps
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
