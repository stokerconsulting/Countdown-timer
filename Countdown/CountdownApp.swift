import SwiftUI

@main
struct CountdownApp: App {
    @State private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
