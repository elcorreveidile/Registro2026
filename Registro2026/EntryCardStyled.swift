//
//  EntryCardStyled.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData

struct EntryCardStyled: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(SpanishDate.short(entry.date))
                    .font(.system(size: 17, weight: .bold, design: .serif))

                Spacer()

                if !entry.mood.isEmpty {
                    Text(entry.mood)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.done.isEmpty {
                Text(entry.done)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(3)
            } else {
                Text("Sin “Hecho” (todavía).")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags.map(\.name), id: \.self) { t in
                            Text("#\(t)")
                                .font(.caption)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Capsule().fill(Color("AppBackground")))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color("CardBorder"), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Spanish Date Formatter (reutilizable)

enum SpanishDate {
    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    /// Formato editorial correcto en español (sin capitalización inglesa)
    static func long(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        return f.string(from: date)
    }
}

