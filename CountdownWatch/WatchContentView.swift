import SwiftUI

struct WatchContentView: View {
    @Environment(WatchStore.self) private var store

    var body: some View {
        NavigationStack {
            if store.events.isEmpty {
                VStack(spacing: 8) {
                    Text("⏳").font(.largeTitle)
                    Text("Geen gebeurtenissen").font(.headline)
                    Text("Voeg ze toe in de Countdown-app op je iPhone.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
            } else {
                List(store.events) { event in
                    NavigationLink(value: event) { row(event) }
                        .listRowBackground(rowBackground(event))
                }
                .navigationTitle("Aftellen")
                .navigationDestination(for: CountdownEvent.self) { WatchDetailView(event: $0) }
            }
        }
    }

    private func row(_ event: CountdownEvent) -> some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack {
                Text(event.emoji).font(.title3)
                VStack(alignment: .leading) {
                    Text(event.title).font(.headline).lineLimit(1)
                    Text(short(event.date.timeIntervalSince(context.date)))
                        .font(.caption.monospacedDigit())
                }
            }
        }
    }

    private func rowBackground(_ event: CountdownEvent) -> some View {
        LinearGradient(colors: Theme.at(event.themeIndex).colors,
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func short(_ remaining: TimeInterval) -> String {
        guard remaining > 0 else { return "🎉 Het is zover!" }
        let s = Int(remaining)
        let d = s / 86400, h = s % 86400 / 3600, m = s % 3600 / 60
        return d > 0 ? "\(d) d \(h) u" : "\(h) u \(m) min"
    }
}

struct WatchDetailView: View {
    let event: CountdownEvent

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = event.date.timeIntervalSince(context.date)
            let s = max(Int(remaining), 0)
            ScrollView {
                VStack(spacing: 6) {
                    Text(event.emoji).font(.largeTitle)
                    Text(event.title).font(.headline).lineLimit(2)
                    if remaining > 0 {
                        Text("\(s / 86400)")
                            .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                        Text("dagen").font(.caption2).textCase(.uppercase)
                        Text(String(format: "%02d:%02d:%02d", s % 86400 / 3600, s % 3600 / 60, s % 60))
                            .font(.title3.monospacedDigit())
                    } else {
                        Text("🎉 Het is zover!").font(.title3.bold())
                    }
                    Text(event.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2).opacity(0.85)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.white)
            .containerBackground(for: .navigation) {
                LinearGradient(colors: Theme.at(event.themeIndex).colors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
}
