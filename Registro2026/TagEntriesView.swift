//
//  TagEntriesView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//
import SwiftUI
import SwiftData

struct TagEntriesView: View {
    let tagName: String
    @State private var searchText = ""

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    private var filtered: [Entry] {
        let base = entries.filter { e in
            e.tags.contains(where: { $0.name == tagName })
        }
        guard !searchText.isEmpty else { return base }
        let q = searchText.lowercased()
        return base.filter { e in
            [e.done, e.thought, e.consumed, e.work, e.mood, e.note]
                .joined(separator: " ")
                .lowercased()
                .contains(q)
        }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if filtered.isEmpty {
                VStack(spacing: 10) {
                    Text("#\(tagName)")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                    Text(searchText.isEmpty ? "No hay entradas con esta etiqueta." : "No hay resultados para esta búsqueda.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { entry in
                            NavigationLink {
                                EntryEditor(entry: entry)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(SpanishDate.short(entry.date))
                                        .font(.system(size: 17, weight: .bold, design: .serif))

                                    if !entry.done.isEmpty {
                                        Text(entry.done)
                                            .font(.system(size: 16, weight: .semibold))
                                            .lineLimit(3)
                                    } else {
                                        Text("Sin “Hecho” (todavía).")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(.secondary)
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
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 22)
                }
            }
        }
        .navigationTitle("#\(tagName)")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Buscar dentro de #\(tagName)…"
        )
    }
}

private enum SpanishDate {
    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}
