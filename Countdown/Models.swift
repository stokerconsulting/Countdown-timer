import Foundation
import Observation

@Observable
final class EventStore {
    static let maxEvents = 5
    private let key = "events.v1"

    var events: [CountdownEvent] {
        didSet {
            save()
            PhoneConnectivity.shared.send(events)
        }
    }

    var canAdd: Bool { events.count < Self.maxEvents }

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) {
            events = decoded
        } else {
            events = []
        }
        events.forEach(NotificationManager.schedule)
    }

    func upsert(_ event: CountdownEvent) {
        if let i = events.firstIndex(where: { $0.id == event.id }) {
            events[i] = event
        } else if canAdd {
            events.append(event)
        }
        events.sort { $0.date < $1.date }
        if let saved = events.first(where: { $0.id == event.id }) {
            NotificationManager.schedule(saved)
        }
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        NotificationManager.cancel(event)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
