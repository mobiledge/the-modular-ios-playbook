import Foundation
import os

/// Tiny logging facade used across the whole app.
///
/// MONOLITH NOTE: a shared utility like this gets called from networking,
/// persistence, and UI alike. In a single target that is convenient; once we
/// split into modules it becomes a shared dependency we must place carefully.
enum Logger {
    private static let osLog = OSLog(subsystem: "com.playbook.iTunesSearchApp", category: "App")

    static func log(_ message: String) {
        os_log("%{public}@", log: osLog, type: .debug, message)
    }
}
