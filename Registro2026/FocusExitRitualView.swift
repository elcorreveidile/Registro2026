//
//  FocusExitRitualView.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import SwiftUI

struct FocusExitRitualView: View {

    let question: String
    let onClose: () -> Void

    @State private var answer: String = ""

    private let paper = Color(red: 0.98, green: 0.97, blue: 0.94)
    private let desk  = Color(red: 0.96, green: 0.95, blue: 0.92)

    var body: some View {
        ZStack(alignment: .bottom) {
            desk.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {

                // X arriba siempre visible
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cerrar ritual")
                }
                .padding(.top, 8)

                Text(question)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)

                TextField("(opcional)", text: $answer)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(paper)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    )

                Spacer(minLength: 120) // deja espacio para que nunca tape la botonera
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Botonera fija abajo, siempre visible incluso con teclado
            VStack(spacing: 10) {
                Button {
                    onClose()
                } label: {
                    Text("Cerrar")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.black.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    onClose()
                } label: {
                    Text("Salir sin responder")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(desk.opacity(0.98))
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .interactiveDismissDisabled(true)
    }
}

