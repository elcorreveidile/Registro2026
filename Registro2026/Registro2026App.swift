import SwiftUI
import SwiftData

@main
struct Registro2026App: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Entry.self,
            Tag.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.locale, Locale(identifier: "es_ES"))
                .modelContainer(sharedModelContainer)
        }
    }
}
