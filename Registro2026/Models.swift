//
//  Models.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import Foundation
import SwiftData

@Model
final class Entry {
    var date: Date

    var done: String
    var thought: String
    var consumed: String
    var work: String
    var mood: String
    var note: String

    // Many-to-many con Tag
    @Relationship(inverse: \Tag.entries)
    var tags: [Tag]

    init(date: Date = .now,
         done: String = "",
         thought: String = "",
         consumed: String = "",
         work: String = "",
         mood: String = "",
         note: String = "",
         tags: [Tag] = []) {
        self.date = date
        self.done = done
        self.thought = thought
        self.consumed = consumed
        self.work = work
        self.mood = mood
        self.note = note
        self.tags = tags
    }
}

@Model
final class Tag {
    // ✅ Unicidad real por nombre normalizado
    @Attribute(.unique)
    var name: String

    @Relationship
    var entries: [Entry]

    init(name: String) {
        self.name = Tag.normalize(name)
        self.entries = []
    }

    /// Normaliza: quita #, espacios y baja a minúsculas
    static func normalize(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
    }
}
