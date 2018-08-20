

import Foundation
struct ListenerKey {
    let command: String
    let key: UUID
    init(command: String, key: UUID) {
        self.command = command
        self.key = key
    }
}
