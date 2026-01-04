import SwiftUI
import SwiftData

@main
struct Registro2026App: App {
    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.locale, Locale(identifier: "es_ES"))
                .preferredColorScheme(.light)   // 👈 clave
        }
        .modelContainer(for: [Entry.self, Tag.self])
    }
}

