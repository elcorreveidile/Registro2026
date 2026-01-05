//
//  TagsIndexView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData

struct TagsIndexView: View {
    @State private var searchText = ""

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    // MARK: - Data

    private var countsAll: [(name: String, count: Int)] {
        var dict: [String: Int] = [:]
        for e in entries {
            for t in e.tags {
                let n = t.name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !n.isEmpty else { continue }
                dict[n, default: 0] += 1
            }
        }

        return dict
            .map { (name: $0.key, count: $0.value) }
            .sorted { a, b in
                if a.count == b.count { return a.name < b.name }
                return a.count > b.count
            }
    }

    private var countsFiltered: [(name: String, count: Int)] {
        guard !searchText.isEmpty else { return countsAll }
        let q = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return countsAll }
        return countsAll.filter { $0.name.lowercased().contains(q) }
    }

    private var topTags: [(name: String, count: Int)] {
        Array(countsFiltered.prefix(10))
    }

    private var groupedByLetter: [(letter: String, items: [(name: String, count: Int)])] {
        let items = countsFiltered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        var buckets: [String: [(name: String, count: Int)]] = [:]
        for it in items {
            let letter = firstIndexLetter(of: it.name)
            buckets[letter, default: []].append(it)
        }

        // Orden editorial: A-Z y al final "#"
        let letters = buckets.keys.sorted { a, b in
            if a == "#" { return false }
            if b == "#" { return true }
            return a < b
        }

        return letters.map { ($0, buckets[$0] ?? []) }
    }

    // MARK: - UI

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    TagsHeader()

                    if countsAll.isEmpty {
                        EmptyTagsCard()
                            .padding(.horizontal)
                            .padding(.top, 4)
                    } else {
                        if !topTags.isEmpty {
                            TopTagsCard(topTags: topTags)
                                .padding(.horizontal)
                        }

                        IndexCard(
                            grouped: groupedByLetter,
                            emptyMessage: countsFiltered.isEmpty ? "No hay coincidencias." : nil
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 22)
                    }
                }
                .padding(.top, 12)
            }
            // ✅ siempre visible en el índice
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar etiqueta…"
            )
        }
        .navigationTitle("Etiquetas")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func firstIndexLetter(of name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }

        // Convertimos a mayúscula “humana”
        let s = String(first).uppercased(with: Locale(identifier: "es_ES"))

        // A–Z (incluye Ñ si la primera letra lo es)
        let allowed = "AÁBCDEÉFGHIÍJKLMNÑOÓPQRSTUÚÜVWXYZ"
        if allowed.contains(s) { return s == "Á" ? "A" : (s == "É" ? "E" : (s == "Í" ? "I" : (s == "Ó" ? "O" : (s == "Ú" ? "U" : s)))) }

        // Si empieza por número/símbolo
        return "#"
    }
}

// MARK: - Header

private struct TagsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Índice temático")
                .font(.system(size: 26, weight: .bold, design: .serif))

            Text("Un índice de libro: toca una etiqueta para ver sus entradas.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal)
    }
}

// MARK: - Top tags

private struct TopTagsCard: View {
    let topTags: [(name: String, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Más usadas")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(topTags, id: \.name) { item in
                        NavigationLink {
                            TagEntriesView(tagName: item.name)
                        } label: {
                            HStack(spacing: 8) {
                                Text("#\(item.name)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Text("\(item.count)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Capsule().fill(Color("AppBackground")))
                                    .overlay(Capsule().strokeBorder(Color("CardBorder"), lineWidth: 1))
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("CardBackground"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color("CardBorder"), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
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

// MARK: - Index card with sections

private struct IndexCard: View {
    let grouped: [(letter: String, items: [(name: String, count: Int)])]
    let emptyMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Índice A–Z")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                Spacer()
            }

            if let emptyMessage {
                Text(emptyMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(grouped, id: \.letter) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.letter)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(Capsule().fill(Color("AppBackground")))
                                .overlay(Capsule().strokeBorder(Color("CardBorder"), lineWidth: 1))

                            VStack(spacing: 8) {
                                ForEach(section.items, id: \.name) { item in
                                    NavigationLink {
                                        TagEntriesView(tagName: item.name)
                                    } label: {
                                        TagRow(name: item.name, count: item.count)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 2)
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

private struct TagRow: View {
    let name: String
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(name)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            Text("\(count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Capsule().fill(Color("AppBackground")))
                .overlay(Capsule().strokeBorder(Color("CardBorder"), lineWidth: 1))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppBackground").opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
    }
}

// MARK: - Empty

private struct EmptyTagsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "tag")
                    .font(.system(size: 18, weight: .bold))
                Text("Aún no hay etiquetas")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }

            Text("Añade etiquetas en tus entradas y aparecerán aquí como índice.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 4)
        .padding(.horizontal)
    }
}

