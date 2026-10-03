import SwiftUI
import UserNotifications

@main
struct CountdownApp: App {
    @State private var store = EventStore()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
