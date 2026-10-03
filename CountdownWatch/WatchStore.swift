import Foundation
import Observation
import WatchConnectivity

/// Ontvangt de events van de iPhone en bewaart de laatste staat lokaal.
@Observable
final class WatchStore {
    private let key = "events.watch.v1"
    @ObservationIgnored private var receiver: Receiver?

    var events: [CountdownEvent] = []

    init() {
        if let data = UserDefaults.standard.data(forKey: key) { apply(data, persist: false) }
        guard WCSession.isSupported() else { return }
        receiver = Receiver { [weak self] data in self?.apply(data) }
    }

    private func apply(_ data: Data, persist: Bool = true) {
        guard let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) else { return }
        events = decoded.sorted { $0.date < $1.date }
        if persist { UserDefaults.standard.set(data, forKey: key) }
    }
}

private final class Receiver: NSObject, WCSessionDelegate {
    private let onData: (Data) -> Void

    init(onData: @escaping (Data) -> Void) {
        self.onData = onData
        super.init()
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func handle(_ context: [String: Any]) {
        guard let data = context["events"] as? Data else { return }
        DispatchQueue.main.async { self.onData(data) }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        handle(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        handle(context)
    }
}
