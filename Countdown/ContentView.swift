import SwiftUI

struct ContentView: View {
    @Environment(EventStore.self) private var store
    @State private var editing: CountdownEvent?
    @State private var adding = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x0F0C29), Color(hex: 0x302B63), Color(hex: 0x24243E)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if store.events.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.events) { event in
                                EventCard(event: event)
                                    .onTapGesture { editing = event }
                                    .contextMenu {
                                        Button("Bewerken", systemImage: "pencil") { editing = event }
                                        Button("Verwijderen", systemImage: "trash", role: .destructive) {
                                            withAnimation { store.delete(event) }
                                        }
                                    }
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .animation(.spring(duration: 0.4), value: store.events)
                    }
                }
            }
            .navigationTitle("Aftellen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { adding = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                    .disabled(!store.canAdd)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(store.events.count)/\(EventStore.maxEvents)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $adding) {
                EventEditor(event: nil)
            }
            .sheet(item: $editing) { event in
                EventEditor(event: event)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("⏳").font(.system(size: 72))
            Text("Nog geen gebeurtenissen").font(.title3.bold())
            Text("Tik op + om je eerste aftelling toe te voegen.")
                .foregroundStyle(.secondary)
            Button("Gebeurtenis toevoegen") { adding = true }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
