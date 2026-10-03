import SwiftUI

@main
struct CountdownWatchApp: App {
    @State private var store = WatchStore()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(store)
        }
    }
}
