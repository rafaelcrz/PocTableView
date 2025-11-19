import Foundation

struct Message {
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(text: String, isFromUser: Bool) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

