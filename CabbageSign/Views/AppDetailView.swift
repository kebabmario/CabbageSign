import SwiftUI

struct AppDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: AppEntry

    var formattedSize: String {
        guard let size = app.size else { return "Unknown" }
        let mb = Double(size) / 1_000_000
        return String(format: "%.1f MB", mb)
    }

    var formattedDate: String {
        guard let date = app.date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    appHeader
                    statsRow
                    getButton
                    if !app.screenshotURLs.isEmpty {
                        previewSection
                    }
                    descriptionSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appHeader: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.accentColor.opacity(0.3))
                    .overlay(Image(systemName: "app.fill").font(.largeTitle).foregroundColor(.white))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(app.developer)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Text(app.tagline.isEmpty ? app.bundleIdentifier : app.tagline)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            Spacer()
        }
    }

    private var statsRow: some View {
        HStack {
            StatItem(label: "VERSION", value: app.version, accentColor: themeManager.currentTheme.accentColor, textColor: themeManager.currentTheme.textColor, secondaryTextColor: themeManager.currentTheme.secondaryTextColor)
            Divider().background(themeManager.currentTheme.secondaryTextColor)
            StatItem(label: "SIZE", value: formattedSize, accentColor: themeManager.currentTheme.accentColor, textColor: themeManager.currentTheme.textColor, secondaryTextColor: themeManager.currentTheme.secondaryTextColor)
            Divider().background(themeManager.currentTheme.secondaryTextColor)
            StatItem(label: "UPDATED", value: formattedDate, accentColor: themeManager.currentTheme.accentColor, textColor: themeManager.currentTheme.textColor, secondaryTextColor: themeManager.currentTheme.secondaryTextColor)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var getButton: some View {
        Group {
            if let destination = URL(string: app.downloadURL) {
                Link(destination: destination) {
                    Text("GET")
                        .font(.title3).fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(app.screenshotURLs, id: \.self) { urlString in
                        AsyncImage(url: URL(string: urlString)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            themeManager.currentTheme.cardColor
                        }
                        .frame(width: 200, height: 400)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
            Text(app.description)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(nil)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let accentColor: Color
    let textColor: Color
    let secondaryTextColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(secondaryTextColor)
            Text(value)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
    }
}
