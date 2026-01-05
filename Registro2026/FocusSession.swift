//
//  FocusSession.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import Foundation
import SwiftData

@MainActor
final class FocusSession: ObservableObject, Identifiable {

    let id = UUID()
    let entry: Entry
    let question: String

    init(entry: Entry) {
        self.entry = entry

        // Lee estilo desde UserDefaults (mismo origen que AppStorage)
        let raw = UserDefaults.standard.string(forKey: FocusRitualKeys.style) ?? FocusRitualStyle.mixed.rawValue
        let style = FocusRitualStyle(rawValue: raw) ?? .mixed

        self.question = FocusRitualQuestions.random(style: style)
    }
}

