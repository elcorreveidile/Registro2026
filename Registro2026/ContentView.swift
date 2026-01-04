//
//  ContentView.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""

    let autoCreateTodayOnAppear: Bool

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    init(autoCreateTodayOnAppear: Bool = false) {
        self.autoCreateTodayOnAppear = autoCreateTodayOnAppear
    }

    private var filtered: [Entry] {
        guard !searchText.isEmpty else { return entries }
        let q = searchText.lowercased()
        return entries.filter { e in
            [e.done, e.thought, e.consumed, e.work, e.mood, e.note]
                .joined(separator: " ")
                .lowercased()
                .contains(q)
            || e.tags.contains(where: { $0.name.lowercased().contains(q) })
        }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    HeaderCard()

                    if filtered.isEmpty {
                        EmptyStateCard()
                            .padding(.horizontal)
                            .padding(.top, 4)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { entry in
                                NavigationLink {
                                    EntryEditor(entry: entry)
                                } label: {
                                    EntryCardStyled(entry: entry)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        context.delete(entry)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        context.delete(entry)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .padding(.bottom, 22)
                    }
                }
            }
            // ✅ AQUÍ, en el ScrollView (no fuera)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar texto o etiquetas…"
            )
        }
        .navigationTitle("Registro 2026")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    createTodayIfMissing()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("Crear entrada de hoy")
            }

            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ExportView(entries: entries)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Exportar")
            }
        }
        .onAppear {
            if autoCreateTodayOnAppear { createTodayIfMissing() }
        }
    }

    private func createTodayIfMissing() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        if entries.contains(where: { cal.isDate($0.date, inSameDayAs: today) }) { return }
        context.insert(Entry(date: today))
    }
}

// MARK: - Header / Empty

private struct HeaderCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22),
                    Color(red: 0.22, green: 0.20, blue: 0.18),
                    Color(red: 0.35, green: 0.27, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: -140, y: -120)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                    Text("2026")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                    Spacer()
                }

                Text("Registro de vida")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("Escritura breve · Etiquetas · Búsqueda · Exportación")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 12)
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)
    }
}

private struct EmptyStateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "book.closed")
                    .font(.system(size: 18, weight: .bold))
                Text("Aún no hay entradas")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }

            Text("Crea la primera con el icono de escribir arriba a la derecha.")
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
    }
}

private struct EntryCardStyled: View {
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
                                .overlay(Capsule().strokeBorder(Color("CardBorder"), lineWidth: 1))
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

private enum SpanishDate {
    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}

