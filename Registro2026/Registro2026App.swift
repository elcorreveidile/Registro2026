//
//  Registro2026App.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI
import SwiftData

@main
struct Registro2026App: App {

    // ✅ Creamos el store UNA sola vez para toda la app
    @StateObject private var coverStore = CoverStore()

    // ✅ SwiftData container
    private var sharedModelContainer: ModelContainer = {
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
                .environmentObject(coverStore)                // ✅ Inyección correcta
                .environment(\.locale, Locale(identifier: "es_ES"))
                .preferredColorScheme(.light)
                .modelContainer(sharedModelContainer)
        }
    }
}

