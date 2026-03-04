import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var sourceService = SourceService()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingAddSource = false
    @State private var newSourceName = ""
    @State private var newSourceURL = ""

    var isIpad: Bool { horizontalSizeClass == .regular }

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
                            .font(isIpad ? .title3 : .body)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: isIpad ? 44 : 36, height: isIpad ? 44 : 36)
                            .contentShape(Rectangle())
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
                .font(isIpad ? .title3 : .headline)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text(source.url)
                .font(isIpad ? .subheadline : .caption)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(1)
        }
        .padding(.vertical, isIpad ? 8 : 4)
    }

    private var emptyState: some View {
        VStack(spacing: isIpad ? 24 : 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: isIpad ? 90 : 60))
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("No Sources")
                .font(isIpad ? .title : .title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text("Add a repo source to browse apps")
                .font(isIpad ? .body : .subheadline)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Button(action: { showingAddSource = true }) {
                Label("Add Source", systemImage: "plus")
                    .font(isIpad ? .title3 : .body)
                    .padding(isIpad ? 18 : 14)
                    .background(themeManager.currentTheme.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    private var addSourceSheet: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button("Cancel") {
                        newSourceName = ""
                        newSourceURL = ""
                        showingAddSource = false
                    }
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .font(isIpad ? .title3 : .body)
                    Spacer()
                    Text("Add Source")
                        .font(isIpad ? .title2 : .headline)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Spacer()
                    Button("Add") {
                        let name = newSourceName.isEmpty
                            ? (URL(string: newSourceURL)?.host ?? newSourceURL)
                            : newSourceName
                        let source = AppSource(name: name, url: newSourceURL)
                        sourceService.addSource(source)
                        newSourceName = ""
                        newSourceURL = ""
                        showingAddSource = false
                    }
                    .disabled(newSourceURL.isEmpty)
                    .foregroundColor(newSourceURL.isEmpty
                        ? themeManager.currentTheme.secondaryTextColor
                        : themeManager.currentTheme.accentColor)
                    .font(isIpad ? .title3 : .body)
                    .fontWeight(.semibold)
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)

                ScrollView {
                    VStack(spacing: isIpad ? 28 : 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repo URL")
                                .font(isIpad ? .title3 : .headline)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            TextField("https://repo.example.com/", text: $newSourceURL)
                                .padding(isIpad ? 18 : 14)
                                .background(themeManager.currentTheme.cardColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .font(isIpad ? .title3 : .body)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Text("Enter the URL of a repo (e.g. https://repo.cypwn.xyz/)")
                                .font(isIpad ? .subheadline : .caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Source Name (optional)")
                                .font(isIpad ? .title3 : .headline)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            TextField("My App Source", text: $newSourceName)
                                .padding(isIpad ? 18 : 14)
                                .background(themeManager.currentTheme.cardColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .font(isIpad ? .title3 : .body)
                                .autocapitalization(.words)
                            Text("If left blank, the name will be taken from the URL.")
                                .font(isIpad ? .subheadline : .caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                        Spacer()
                    }
                    .padding(isIpad ? 28 : 20)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct SourceAppsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let source: AppSource
    @State private var apps: [AppEntry] = []
    @State private var isLoading = false
    @State private var error: String?

    var isIpad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .tint(themeManager.currentTheme.accentColor)
            } else if let error = error {
                Text(error).foregroundColor(.red).padding()
            } else if isIpad {
                let columns = [GridItem(.adaptive(minimum: 300), spacing: 16)]
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(apps) { app in
                            NavigationLink(destination: AppDetailView(app: app)) {
                                AppRowView(app: app)
                                    .padding(.horizontal, 8)
                                    .background(themeManager.currentTheme.cardColor)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding()
                }
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let app: AppEntry

    var isIpad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        HStack(spacing: isIpad ? 16 : 12) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.cardColor)
                    .overlay(Image(systemName: "app").foregroundColor(.gray))
            }
            .frame(width: isIpad ? 70 : 50, height: isIpad ? 70 : 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(isIpad ? .title3 : .headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(app.developer)
                    .font(isIpad ? .body : .subheadline)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                Text("v\(app.version)")
                    .font(isIpad ? .subheadline : .caption)
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
            Spacer()
        }
        .padding(.vertical, isIpad ? 8 : 4)
    }
}
