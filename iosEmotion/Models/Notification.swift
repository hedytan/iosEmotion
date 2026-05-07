import Foundation

struct AppNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let message: String
    let timestamp: Date = Date()
    var isRead: Bool = false
    
    enum NotificationType {
        case like
        case comment
        case system
    }
}
