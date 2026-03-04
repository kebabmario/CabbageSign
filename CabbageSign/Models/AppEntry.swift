import Foundation

struct AppEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var bundleIdentifier: String
    var version: String
    var developer: String
    var description: String
    var iconURL: String?
    var downloadURL: String
    var size: Int?
    var date: Date?
    var screenshotURLs: [String] = []
    var tagline: String = ""
}
