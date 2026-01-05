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

    private var filteredEntries: [Entry] {
        let byTag = entries.filter { e in
            e.tags.contains(where: { $0.name == tagName })
        }

        guard !searchText.isEmpty else { return byTag }
        let q = searchText.lowercased()

        return byTag.filter { e in
            [e.done, e.thought, e.consumed, e.work, e.mood, e.note]
                .joined(separator: " ")
                .lowercased()
                .contains(q)
        }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if filteredEntries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text("Sin entradas")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                    Text("No hay entradas con esta etiqueta (o no coinciden con la búsqueda).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                EntryEditor(entry: entry)
                            } label: {
                                EntryCardStyled(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 22)
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar dentro de #\(tagName)…"
                )
            }
        }
        .navigationTitle("#\(tagName)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

