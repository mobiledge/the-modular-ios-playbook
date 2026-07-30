import Foundation
import os

/// Internal logging facade for the infrastructure layer (networking, persistence).
/// Not part of the public API — callers of the package never see it.
enum Logger {
    private static let osLog = OSLog(subsystem: "com.playbook.iTunesSearchApp", category: "Infrastructure")

    static func log(_ message: String) {
        os_log("%{public}@", log: osLog, type: .debug, message)
    }
}
