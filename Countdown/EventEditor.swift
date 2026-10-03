import SwiftUI

struct EventEditor: View {
    @Environment(EventStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let existing: CountdownEvent?
    @State private var title: String
    @State private var emoji: String
    @State private var date: Date
    @State private var themeIndex: Int
    @State private var notify: Bool

    private let emojis = ["🎂", "✈️", "🎄", "💍", "🎓", "🏖️", "🎉", "🏆", "🏠", "👶", "🎁", "⚽️"]

    init(event: CountdownEvent?) {
        existing = event
        _title = State(initialValue: event?.title ?? "")
        _emoji = State(initialValue: event?.emoji ?? "🎉")
        _date = State(initialValue: event?.date ?? Calendar.current.date(byAdding: .day, value: 30, to: .now)!)
        _themeIndex = State(initialValue: event?.themeIndex ?? 0)
        _notify = State(initialValue: event?.notify ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Naam") {
                    TextField("Bijv. Vakantie", text: $title)
                }
                Section("Icoon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojis, id: \.self) { e in
                            Text(e).font(.title)
                                .frame(width: 44, height: 44)
                                .background(emoji == e ? Color.accentColor.opacity(0.3) : .clear, in: Circle())
                                .onTapGesture { emoji = e }
                        }
                    }
                }
                Section("Datum en tijd") {
                    DatePicker("Moment", selection: $date, in: Date.now...)
                }
                Section {
                    Toggle("Meldingen", isOn: $notify)
                } footer: {
                    Text("Een dag van tevoren en op het moment zelf.")
                }
                Section("Kleur") {
                    HStack(spacing: 14) {
                        ForEach(Theme.all) { theme in
                            Circle()
                                .fill(LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(.white, lineWidth: themeIndex == theme.id ? 3 : 0))
                                .onTapGesture { themeIndex = theme.id }
                        }
                    }
                }
                if let existing {
                    Section {
                        Button("Verwijderen", role: .destructive) {
                            store.delete(existing)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "Nieuwe aftelling" : "Bewerken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bewaar", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        var event = existing ?? CountdownEvent(title: "", emoji: emoji, date: date, themeIndex: themeIndex)
        event.title = title.trimmingCharacters(in: .whitespaces)
        event.emoji = emoji
        event.date = date
        event.themeIndex = themeIndex
        event.notify = notify
        if notify { NotificationManager.requestAuthorization() }
        store.upsert(event)
        dismiss()
    }
}
