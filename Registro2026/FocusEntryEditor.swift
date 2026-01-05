
//  FocusEntryEditor.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import SwiftUI
import SwiftData

/// Editor minimalista para el modo enfoque.
/// Solo “Hecho” + “Nota suelta” (opcional), con tipografía cuaderno y cursor automático.
struct FocusEntryEditor: View {

    @Bindable var entry: Entry

    @FocusState private var isFocused: Bool

    // Ajustes visuales “cuaderno”
    private let paper = Color(red: 0.98, green: 0.97, blue: 0.94)
    private let desk  = Color(red: 0.96, green: 0.95, blue: 0.92)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Fecha editorial, discreta
                Text(entry.date.formatted(date: .complete, time: .omitted))
                    .font(.system(.footnote, design: .serif))
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)

                // Campo principal (Hecho)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hecho")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary.opacity(0.9))

                    TextEditor(text: $entry.done)
                        .focused($isFocused)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .lineSpacing(7)
                        .padding(16)
                        .frame(minHeight: 220)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(paper)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                }

                // Nota suelta (opcional, más pequeña)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nota")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary.opacity(0.9))

                    TextEditor(text: $entry.note)
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .lineSpacing(5)
                        .padding(14)
                        .frame(minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(paper.opacity(0.85))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                }

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .background(desk.ignoresSafeArea())
        .onAppear {
            // ✅ Cursor automático (con un pelín de delay para que funcione siempre)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isFocused = true
            }
        }
    }
}

