//
//  Models.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI
import SwiftData

@Model
final class Tag: Identifiable {
    @Attribute(.unique) var name: String
    init(name: String) { self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
}

@Model
final class Entry: Identifiable {
    var date: Date

    var done: String
    var thought: String
    var consumed: String
    var work: String
    var mood: String
    var note: String

    @Relationship(deleteRule: .nullify) var tags: [Tag] = []

    init(date: Date = .now,
         done: String = "",
         thought: String = "",
         consumed: String = "",
         work: String = "",
         mood: String = "",
         note: String = "") {
        self.date = date
        self.done = done
        self.thought = thought
        self.consumed = consumed
        self.work = work
        self.mood = mood
        self.note = note
    }
}

