import Foundation
import WatchConnectivity

/// Stuurt de events naar de Apple Watch via applicationContext
/// (alleen de laatste staat telt, ook als de watch even niet bereikbaar is).
final class PhoneConnectivity: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivity()

    private var latest: Data?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(_ events: [CountdownEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        latest = data
        push()
    }

    private func push() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated,
              WCSession.default.isWatchAppInstalled,
              let latest else { return }
        try? WCSession.default.updateApplicationContext(["events": latest])
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        push()
    }

    func sessionWatchStateDidChange(_ session: WCSession) { push() }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}
