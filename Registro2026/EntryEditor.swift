//
//  EntryEditor.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI
import SwiftData

struct EntryEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var entry: Entry
    @State private var tagInput = ""
    @State private var showTagInfo = false

    var body: some View {
        Form {
            Section("Fecha") {
                DatePicker("", selection: $entry.date, displayedComponents: .date)
            }

            Section("Registro") {
                TextField("Hecho", text: $entry.done, axis: .vertical)
                TextField("Pensado", text: $entry.thought, axis: .vertical)
                TextField("Leído / visto / escuchado", text: $entry.consumed, axis: .vertical)
                TextField("Trabajo / creación", text: $entry.work, axis: .vertical)
                TextField("Estado de ánimo (1 palabra)", text: $entry.mood)
                TextField("Nota suelta", text: $entry.note, axis: .vertical)
            }

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        TextField("Añade: docencia, poesía, IA", text: $tagInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        Button {
                            showTagInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Aplicar etiquetas") {
                        applyTags()
                    }

                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags) { tag in
                                    HStack(spacing: 6) {
                                        Text("#\(tag.name)")
                                            .font(.caption)

                                        Button {
                                            remove(tag)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }
                }
            } header: {
                Text("Etiquetas")
            } footer: {
                Text("Se guardan normalizadas: sin #, sin espacios, en minúsculas. Así no se duplican.")
            }
        }
        .navigationTitle(entry.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Botón “Listo” útil (en vez de un guardar raro)
            ToolbarItem(placement: .topBarTrailing) {
                Button("Listo") {
                    dismiss()
                }
            }
        }
        .alert("Cómo funcionan las etiquetas", isPresented: $showTagInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Escribe separadas por coma. Se convertirán en minúsculas y se eliminará el símbolo # si lo pones. Ej.: “Poesía, #Docencia, IA”.")
        }
    }

    // MARK: - Tag logic

    private func applyTags() {
        let parts = tagInput
            .split(separator: ",")
            .map { String($0) }
            .map { Tag.normalize($0) }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else {
            tagInput = ""
            return
        }

        for name in parts {
            let t = getOrCreateTag(named: name)

            // Evita duplicar la relación en la Entry
            if !entry.tags.contains(where: { $0.name == t.name }) {
                entry.tags.append(t)
            }
        }

        tagInput = ""

        // Limpieza opcional: borra tags huérfanos si los hubiera
        deleteOrphanTagsIfAny()
    }

    private func remove(_ tag: Tag) {
        entry.tags.removeAll { $0.name == tag.name }
        deleteOrphanTagsIfAny()
    }

    /// Devuelve un Tag único por nombre (normalizado).
    private func getOrCreateTag(named normalizedName: String) -> Tag {
        let fetch = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == normalizedName })

        if let existing = try? context.fetch(fetch).first {
            return existing
        }

        // Si no existe, lo creamos
        let new = Tag(name: normalizedName)
        context.insert(new)

        // Si hubiese conflicto de unicidad por carrera (poco común), refetch.
        // SwiftData puede lanzar error al persistir; aquí minimizamos duplicados a nivel de UI.
        if let existingAfterInsert = try? context.fetch(fetch).first {
            return existingAfterInsert
        }

        return new
    }

    /// Borra tags que ya no están enlazados a ninguna Entry.
    /// (Evita que el “Índice temático” se llene de etiquetas fantasma.)
    private func deleteOrphanTagsIfAny() {
        let fetchAll = FetchDescriptor<Tag>()
        guard let all = try? context.fetch(fetchAll) else { return }

        for t in all {
            if t.entries.isEmpty {
                context.delete(t)
            }
        }
    }
}

