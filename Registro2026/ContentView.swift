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

    // ✅ Ventana de "Hoy": últimos N días
    private let daysVisible: Int = 14

    // ✅ Abrir editor normal
    @State private var selectedEntry: Entry? = nil

    // ✅ Modo escritura sin distracciones (full screen) — ahora por sesión estable
    @State private var focusSession: FocusSession? = nil

    init(autoCreateTodayOnAppear: Bool = false) {
        self.autoCreateTodayOnAppear = autoCreateTodayOnAppear
    }

    private var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -daysVisible, to: .now) ?? .distantPast
    }

    private var filtered: [Entry] {
        let base = entries.filter { $0.date >= cutoffDate }

        guard !searchText.isEmpty else { return base }

        let q = searchText.lowercased()

        return base.filter { e in
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
                                // ✅ Mantengo tu navegación directa (no usamos selectedEntry aquí)
                                NavigationLink {
                                    EntryEditor(entry: entry)
                                } label: {
                                    EntryCardStyled(entry: entry)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {

                                    // ✅ Enfoque desde una entrada existente:
                                    // crea una sesión nueva (pregunta nueva), pero estable DURANTE esa sesión
                                    Button {
                                        focusSession = FocusSession(entry: entry)
                                    } label: {
                                        Label("Escritura en enfoque", systemImage: "pencil.and.outline")
                                    }

                                    Divider()

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
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar texto o etiquetas…"
            )
        }
        .navigationTitle("Registro 2026")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)

        // ✅ Editor normal: destino estable (fuera de Lazy)
        .navigationDestination(item: $selectedEntry) { entry in
            EntryEditor(entry: entry)
        }

        .toolbar {

            // ✅ Botón: abre la entrada de hoy (editor normal)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    openTodayInEditor()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("Abrir entrada de hoy")
            }

            // ✅ Botón: enfoque (hoy) — crea sesión estable
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    openFocusWriterForToday()
                } label: {
                    Image(systemName: "pencil.and.outline")
                }
                .accessibilityLabel("Escritura sin distracciones")
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
            if autoCreateTodayOnAppear {
                _ = ensureTodayEntry()
            }
        }

        // ✅ FocusWriter por sesión (NO por Entry). Esto evita recreaciones raras y fija la pregunta.
        .fullScreenCover(item: $focusSession) { session in
            FocusWriterView(session: session)
        }
    }

    // MARK: - Acciones

    private func openTodayInEditor() {
        let entry = ensureTodayEntry()
        selectedEntry = entry
    }

    private func openFocusWriterForToday() {
        let entry = ensureTodayEntry()
        focusSession = FocusSession(entry: entry)
    }

    /// Devuelve la Entry de hoy (existente o nueva).
    /// Aquí NO devolvemos Optional: así no hay pantallas en blanco.
    private func ensureTodayEntry() -> Entry {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        if let existing = entries.first(where: { cal.isDate($0.date, inSameDayAs: today) }) {
            return existing
        }

        let newEntry = Entry(date: today)
        context.insert(newEntry)
        return newEntry
    }
}

// MARK: - Header / Empty

private struct HeaderCard: View {

    @EnvironmentObject private var coverStore: CoverStore

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            headerBackground
                .overlay(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.05),
                            .black.opacity(0.22),
                            .black.opacity(0.45)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .accessibilityHidden(true)

            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: -140, y: -120)
                .accessibilityHidden(true)

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
                    .foregroundStyle(.white.opacity(0.90))
            }
            .padding(.leading, 22)
            .padding(.trailing, 18)
            .padding(.top, 18)
            .padding(.bottom, 26)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 12)
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(coverStore.hasCustomCover ? "Portada personalizada. Registro de vida 2026." : "Portada por defecto. Registro de vida 2026.")
    }

    @ViewBuilder
    private var headerBackground: some View {
        if let img = coverStore.coverUIImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

        } else if UIImage(named: "HeaderImage") != nil {
            Image("HeaderImage")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22),
                    Color(red: 0.22, green: 0.20, blue: 0.18),
                    Color(red: 0.35, green: 0.27, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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

