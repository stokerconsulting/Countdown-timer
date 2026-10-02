import SwiftUI

struct EventCard: View {
    let event: CountdownEvent

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let remaining = event.date.timeIntervalSince(now)
            let total = max(event.date.timeIntervalSince(event.created), 1)
            let progress = min(max(1 - remaining / total, 0), 1)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Text(event.emoji)
                        .font(.system(size: 34))
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.2), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title).font(.title3.bold()).lineLimit(1)
                        Text(event.date.formatted(date: .long, time: .shortened))
                            .font(.caption).opacity(0.85)
                    }
                    Spacer()
                    ring(progress: progress)
                }

                if remaining > 0 {
                    let p = parts(remaining)
                    HStack(spacing: 10) {
                        unit(p.days, "dagen")
                        unit(p.hours, "uur")
                        unit(p.minutes, "min")
                        unit(p.seconds, "sec")
                    }
                } else {
                    Text("🎉 Het is zover!")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(
                LinearGradient(colors: Theme.at(event.themeIndex).colors,
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .shadow(color: Theme.at(event.themeIndex).colors[0].opacity(0.45), radius: 14, y: 8)
        }
    }

    private func ring(progress: Double) -> some View {
        ZStack {
            Circle().stroke(.white.opacity(0.25), lineWidth: 5)
            Circle().trim(from: 0, to: progress)
                .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%").font(.caption2.bold().monospacedDigit())
        }
        .frame(width: 48, height: 48)
    }

    private func unit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                .contentTransition(.numericText(countsDown: true))
            Text(label).font(.caption2).textCase(.uppercase).opacity(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func parts(_ interval: TimeInterval) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let s = Int(interval)
        return (s / 86400, s % 86400 / 3600, s % 3600 / 60, s % 60)
    }
}
