import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var sourceService = SourceService()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var allApps: [AppEntry] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showSearch = false

    var isIpad: Bool { horizontalSizeClass == .regular }

    var filteredApps: [AppEntry] {
        if searchText.isEmpty { return allApps }
        return allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: isIpad ? 32 : 24) {
                        if showSearch {
                            TextField("Search apps...", text: $searchText)
                                .padding()
                                .background(themeManager.currentTheme.cardColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .font(isIpad ? .title3 : .body)
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
                .font(isIpad ? .title : .title2).fontWeight(.bold)
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
                .font(isIpad ? .title : .title2).fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.horizontal)

            if isIpad {
                let columns = [GridItem(.adaptive(minimum: 120), spacing: 20)]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredApps) { app in
                        NavigationLink(destination: AppDetailView(app: app)) {
                            AppCard(app: app)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
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
    }

    private var emptyBrowseState: some View {
        VStack(spacing: isIpad ? 24 : 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: isIpad ? 90 : 60))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("No Apps Found")
                .font(isIpad ? .title : .title2).fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text("Add sources in the Library tab to browse apps")
                .font(isIpad ? .body : .subheadline)
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let app: AppEntry

    var isIpad: Bool { horizontalSizeClass == .regular }
    var cardWidth: CGFloat { isIpad ? 420 : 300 }
    var imageHeight: CGFloat { isIpad ? 210 : 150 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                themeManager.currentTheme.accentColor.opacity(0.3)
            }
            .frame(width: cardWidth, height: imageHeight)
            .clipped()
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(isIpad ? .title3 : .headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(app.tagline.isEmpty ? app.description : app.tagline)
                    .font(isIpad ? .subheadline : .caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .lineLimit(2)
            }
        }
        .frame(width: cardWidth)
        .padding(12)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
}

struct AppCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let app: AppEntry

    var isIpad: Bool { horizontalSizeClass == .regular }
    var iconSize: CGFloat { isIpad ? 100 : 70 }
    var cardWidth: CGFloat { isIpad ? 120 : 80 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.accentColor.opacity(0.3))
                    .overlay(Image(systemName: "app.fill").font(.system(size: iconSize * 0.45)).foregroundColor(.white))
            }
            .frame(width: iconSize, height: iconSize)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(app.name)
                .font(isIpad ? .subheadline : .caption).fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .lineLimit(1)
            Text(app.developer)
                .font(isIpad ? .caption : .caption2)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(1)
        }
        .frame(width: cardWidth)
    }
}
