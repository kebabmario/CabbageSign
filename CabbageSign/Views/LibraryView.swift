import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var sourceService = SourceService()
    @State private var showingAddSource = false
    @State private var newSourceName = ""
    @State private var newSourceURL = ""

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()

                List {
                    ForEach(sourceService.sources) { source in
                        NavigationLink(destination: SourceAppsView(source: source)) {
                            sourceRow(source)
                        }
                        .listRowBackground(themeManager.currentTheme.cardColor)
                    }
                    .onDelete(perform: sourceService.removeSource)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                if sourceService.sources.isEmpty {
                    emptyState
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSource = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSource) {
            addSourceSheet
        }
    }

    private func sourceRow(_ source: AppSource) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(source.name)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text(source.url)
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("No Sources")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text("Add a source to browse apps")
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Button(action: { showingAddSource = true }) {
                Label("Add Source", systemImage: "plus")
                    .padding()
                    .background(themeManager.currentTheme.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    private var addSourceSheet: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Source Name")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        TextField("My App Source", text: $newSourceName)
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(12)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        TextField("https://example.com/apps.json", text: $newSourceURL)
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(12)
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showingAddSource = false }
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let source = AppSource(name: newSourceName, url: newSourceURL)
                        sourceService.addSource(source)
                        newSourceName = ""
                        newSourceURL = ""
                        showingAddSource = false
                    }
                    .disabled(newSourceName.isEmpty || newSourceURL.isEmpty)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
        }
    }
}

struct SourceAppsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let source: AppSource
    @State private var apps: [AppEntry] = []
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .tint(themeManager.currentTheme.accentColor)
            } else if let error = error {
                Text(error).foregroundColor(.red).padding()
            } else {
                List(apps) { app in
                    NavigationLink(destination: AppDetailView(app: app)) {
                        AppRowView(app: app)
                    }
                    .listRowBackground(themeManager.currentTheme.cardColor)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(source.name)
        .task {
            isLoading = true
            do {
                apps = try await SourceService().fetchApps(from: source)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct AppRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: AppEntry

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.cardColor)
                    .overlay(Image(systemName: "app").foregroundColor(.gray))
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(app.developer)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                Text("v\(app.version)")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
