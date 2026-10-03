import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private static var center: UNUserNotificationCenter { .current() }

    static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(_ event: CountdownEvent) {
        cancel(event)
        guard event.notify else { return }

        add(event, suffix: "now", at: event.date,
            title: "\(event.emoji) \(event.title)", body: "Het is zover!")

        if let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: event.date) {
            add(event, suffix: "day", at: dayBefore,
                title: "\(event.emoji) \(event.title)", body: "Nog 1 dag te gaan!")
        }
    }

    static func cancel(_ event: CountdownEvent) {
        center.removePendingNotificationRequests(withIdentifiers: ids(event))
    }

    private static func ids(_ event: CountdownEvent) -> [String] {
        ["now", "day"].map { "\(event.id.uuidString)-\($0)" }
    }

    private static func add(_ event: CountdownEvent, suffix: String, at date: Date,
                            title: String, body: String) {
        guard date > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: "\(event.id.uuidString)-\(suffix)",
                                         content: content, trigger: trigger))
    }

    // Toon meldingen ook als de app open staat.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
