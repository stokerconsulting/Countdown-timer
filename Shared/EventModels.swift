import SwiftUI

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

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var emoji: String
    var date: Date
    var created: Date = .now
    var themeIndex: Int
    var notify: Bool = true

    init(id: UUID = UUID(), title: String, emoji: String, date: Date,
         created: Date = .now, themeIndex: Int, notify: Bool = true) {
        self.id = id; self.title = title; self.emoji = emoji; self.date = date
        self.created = created; self.themeIndex = themeIndex; self.notify = notify
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        emoji = try c.decode(String.self, forKey: .emoji)
        date = try c.decode(Date.self, forKey: .date)
        created = try c.decode(Date.self, forKey: .created)
        themeIndex = try c.decode(Int.self, forKey: .themeIndex)
        notify = try c.decodeIfPresent(Bool.self, forKey: .notify) ?? true
    }
}
