import Foundation

enum SigningJobStatus: String, Codable {
    case pending = "pending"
    case queued = "queued"
    case inProgress = "in_progress"
    case completed = "completed"
    case failed = "failed"
}

struct SigningJob: Identifiable, Codable {
    var id: UUID = UUID()
    var workflowRunId: Int?
    var status: SigningJobStatus = .pending
    var conclusion: String?
    var artifactURL: String?
    var createdAt: Date = Date()
    var ipaName: String
}
