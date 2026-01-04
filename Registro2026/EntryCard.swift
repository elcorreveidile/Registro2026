//
//  EntryCard.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI

struct EntryCard: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.date, style: .date)
                    .font(.headline)
                Spacer()
                if !entry.mood.isEmpty {
                    Text(entry.mood)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.done.isEmpty {
                Text(entry.done)
                    .font(.body)
                    .lineLimit(3)
            }

            if !entry.tags.isEmpty {
                TagWrap(tags: entry.tags.map(\.name))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06))
        )
    }
}

struct TagWrap: View {
    let tags: [String]

    var body: some View {
        // Wrap sencillo: en horizontal con scroll (queda muy bien y evita líos)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { t in
                    Text("#\(t)")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

