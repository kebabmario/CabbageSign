import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var sourceService = SourceService()
    @State private var allApps: [AppEntry] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showSearch = false

    var filteredApps: [AppEntry] {
        if searchText.isEmpty { return allApps }
        return allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if showSearch {
                            TextField("Search apps...", text: $searchText)
                                .padding()
                                .background(themeManager.currentTheme.cardColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .padding(.horizontal)
                        }

                        if !filteredApps.isEmpty {
                            newsSection
                            newAndUpdatedSection
                        } else if isLoading {
                            HStack { Spacer(); ProgressView().tint(themeManager.currentTheme.accentColor); Spacer() }
                                .padding()
                        } else {
                            emptyBrowseState
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showSearch.toggle() } }) {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                }
            }
        }
        .task { await loadApps() }
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("News")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredApps.prefix(5)) { app in
                        NewsCard(app: app)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var newAndUpdatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New & Updated")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredApps) { app in
                        NavigationLink(destination: AppDetailView(app: app)) {
                            AppCard(app: app)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var emptyBrowseState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("No Apps Found")
                .font(.title2).fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text("Add sources in the Library tab to browse apps")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private func loadApps() async {
        isLoading = true
        var apps: [AppEntry] = []
        for source in sourceService.sources {
            let fetched = (try? await sourceService.fetchApps(from: source)) ?? []
            apps.append(contentsOf: fetched)
        }
        allApps = apps
        isLoading = false
    }
}

struct NewsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: AppEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                themeManager.currentTheme.accentColor.opacity(0.3)
            }
            .frame(width: 300, height: 150)
            .clipped()
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(app.tagline.isEmpty ? app.description : app.tagline)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .lineLimit(2)
            }
        }
        .frame(width: 300)
        .padding(12)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
}

struct AppCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: AppEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.accentColor.opacity(0.3))
                    .overlay(Image(systemName: "app.fill").font(.largeTitle).foregroundColor(.white))
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(app.name)
                .font(.caption).fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .lineLimit(1)
            Text(app.developer)
                .font(.caption2)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}
