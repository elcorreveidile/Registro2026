//
//  FocusRitualSettingsView.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import SwiftUI

struct FocusRitualSettingsView: View {

    // Persistencia robusta y simple
    @AppStorage(FocusRitualKeys.isEnabled) private var ritualEnabled: Bool = true
    @AppStorage(FocusRitualKeys.style) private var ritualStyleRaw: String = FocusRitualStyle.mixed.rawValue

    private var style: FocusRitualStyle {
        FocusRitualStyle(rawValue: ritualStyleRaw) ?? .mixed
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {

                    headerCard
                        .padding(.horizontal)

                    enabledCard
                        .padding(.horizontal)

                    styleCard
                        .padding(.horizontal)

                    hintCard
                        .padding(.horizontal)

                    Spacer(minLength: 22)
                }
                .padding(.top, 12)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle("Enfoque")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ritual de cierre")
                .font(.system(size: 22, weight: .bold, design: .serif))
            Text("Una pregunta breve al salir del modo escritura. Pequeña fricción, cierre humano.")
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
    }

    private var enabledCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activación")
                .font(.system(size: 18, weight: .bold, design: .serif))

            Toggle(isOn: $ritualEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mostrar ritual al salir")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(ritualEnabled ? "Activado" : "Desactivado")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.primary)
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

    private var styleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estilo")
                .font(.system(size: 18, weight: .bold, design: .serif))

            VStack(spacing: 8) {
                ForEach(FocusRitualStyle.allCases) { option in
                    styleRow(option)
                }
            }
            .opacity(ritualEnabled ? 1 : 0.45)
            .allowsHitTesting(ritualEnabled)
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

    private func styleRow(_ option: FocusRitualStyle) -> some View {
        Button {
            ritualStyleRaw = option.rawValue
        } label: {
            HStack(spacing: 12) {
                Image(systemName: option.rawValue == ritualStyleRaw ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(option.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
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
        .buttonStyle(.plain)
    }

    private var hintCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Privacidad")
                .font(.system(size: 18, weight: .bold, design: .serif))
            Text("El ritual no analiza tu texto. Solo muestra una pregunta elegida del estilo que tú marques.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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

