import Foundation

struct AppSource: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var url: String
}
