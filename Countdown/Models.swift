import SwiftUI
import Observation

struct Theme: Identifiable {
    let id: Int
    let name: String
    let colors: [Color]

    static let all: [Theme] = [
        Theme(id: 0, name: "Zonsondergang", colors: [Color(hex: 0xFF512F), Color(hex: 0xDD2476)]),
        Theme(id: 1, name: "Oceaan", colors: [Color(hex: 0x2193B0), Color(hex: 0x6DD5ED)]),
        Theme(id: 2, name: "Bos", colors: [Color(hex: 0x11998E), Color(hex: 0x38EF7D)]),
        Theme(id: 3, name: "Nacht", colors: [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)]),
        Theme(id: 4, name: "Goud", colors: [Color(hex: 0xF7971E), Color(hex: 0xFFD200)]),
    ]

    static func at(_ index: Int) -> Theme { all[index % all.count] }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct CountdownEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var emoji: String
    var date: Date
    var created: Date = .now
    var themeIndex: Int
}

@Observable
final class EventStore {
    static let maxEvents = 5
    private let key = "events.v1"

    var events: [CountdownEvent] {
        didSet { save() }
    }

    var canAdd: Bool { events.count < Self.maxEvents }

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) {
            events = decoded
        } else {
            events = []
        }
    }

    func upsert(_ event: CountdownEvent) {
        if let i = events.firstIndex(where: { $0.id == event.id }) {
            events[i] = event
        } else if canAdd {
            events.append(event)
        }
        events.sort { $0.date < $1.date }
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
