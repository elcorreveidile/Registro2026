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
    @Bindable var entry: Entry
    @State private var tagInput = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                EditorHeader(date: entry.date, mood: entry.mood)

                CardSection(title: "Fecha", systemImage: "calendar") {
                    DatePicker("Día", selection: $entry.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                CardSection(title: "Registro", systemImage: "square.and.pencil") {
                    LabeledField(title: "Hecho", placeholder: "Qué has hecho hoy…", text: $entry.done, isMultiline: true)
                    LabeledField(title: "Pensado", placeholder: "Qué te ha rondado la cabeza…", text: $entry.thought, isMultiline: true)
                    LabeledField(title: "Leído / visto / escuchado", placeholder: "Libros, series, música…", text: $entry.consumed, isMultiline: true)
                    LabeledField(title: "Trabajo / creación", placeholder: "Qué avanzaste o creaste…", text: $entry.work, isMultiline: true)
                    LabeledField(title: "Estado de ánimo (1 palabra)", placeholder: "sereno, eléctrico, cansado…", text: $entry.mood, isMultiline: false)
                    LabeledField(title: "Nota suelta", placeholder: "Una frase rápida…", text: $entry.note, isMultiline: true)
                }

                CardSection(title: "Etiquetas", systemImage: "tag") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("docencia, poesía, IA…", text: $tagInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Button { applyTags() } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Aplicar etiquetas")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.20, green: 0.40, blue: 0.98),
                                                Color(red: 0.55, green: 0.25, blue: 0.92),
                                                Color(red: 0.98, green: 0.45, blue: 0.55)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }

                        if !entry.tags.isEmpty {
                            TagChips(tags: entry.tags.map(\.name)) { name in
                                entry.tags.removeAll { $0.name == name }
                            }
                            .padding(.top, 4)
                        } else {
                            Text("Sin etiquetas todavía.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }

                Spacer(minLength: 18)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationTitle(SpanishDate.short(entry.date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { hideKeyboard() } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .accessibilityLabel("Listo")
            }
        }
    }

    private func applyTags() {
        let parts = tagInput
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for p in parts {
            let normalized = p.lowercased()
            let fetch = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == normalized })

            if let existing = try? context.fetch(fetch).first {
                if !entry.tags.contains(where: { $0.name == existing.name }) {
                    entry.tags.append(existing)
                }
            } else {
                let new = Tag(name: normalized)
                context.insert(new)
                entry.tags.append(new)
            }
        }
        tagInput = ""
    }

    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

// MARK: - UI Components

private struct EditorHeader: View {
    let date: Date
    let mood: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.40, blue: 0.98),
                    Color(red: 0.55, green: 0.25, blue: 0.92),
                    Color(red: 0.98, green: 0.45, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 35)
                .offset(x: -110, y: -120)

            VStack(alignment: .leading, spacing: 8) {
                Text(SpanishDate.long(date))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if !mood.isEmpty {
                    Text("Ánimo: \(mood)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                } else {
                    Text("¿Cómo estás hoy?")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.18))
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

private struct CardSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            content
        }
        .padding(16)
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

private struct LabeledField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isMultiline: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...10)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                TextField(placeholder, text: $text)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

private struct TagChips: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { t in
                    Button {
                        onRemove(t)
                    } label: {
                        HStack(spacing: 6) {
                            Text("#\(t)")
                                .font(.caption)
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .opacity(0.85)
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Spanish Date Formatter

private enum SpanishDate {
    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    static func long(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .full
        f.timeStyle = .none
        return f.string(from: date)
    }
}

