import AppKit

extension NSRunningApplication {
    var resolvedProcessIdentifier: pid_t? {
        if processIdentifier > 0 { return processIdentifier }

        // Xcode 27 Device Hub reports -1 after its launcher hands off to the real process.
        // WindowServer still provides the owner PID, including for off-screen windows.
        guard let windows = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        var visitedPids: Set<pid_t> = []
        for window in windows {
            guard let pid = window[kCGWindowOwnerPID as String] as? pid_t,
                  pid > 0,
                  visitedPids.insert(pid).inserted,
                  NSRunningApplication(processIdentifier: pid) == self
            else { continue }
            return pid
        }
        return nil
    }

    var idForDebug: String {
        "PID: \(processIdentifier) ID: \(bundleIdentifier ?? executableURL?.description ?? "")"
    }
}
