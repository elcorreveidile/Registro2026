//
//  SettingsView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    header

                    focusCard
                        .padding(.horizontal)

                    privacyCard
                        .padding(.horizontal)

                    exportCard
                        .padding(.horizontal)

                    aboutCard
                        .padding(.horizontal)

                    Spacer(minLength: 22)
                }
                .padding(.top, 12)
                .padding(.bottom, 22)
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ajustes")
                .font(.system(size: 28, weight: .bold, design: .serif))
            Text("Privacidad, exportación y opciones.")
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
        .padding(.horizontal)
    }

    // ✅ Enfoque (ritual)
    private var focusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enfoque")
                .font(.system(size: 18, weight: .bold, design: .serif))

            NavigationLink {
                FocusRitualSettingsView()
            } label: {
                SettingsRow(
                    title: "Ritual de cierre",
                    subtitle: "Activa y elige estilo (mixto, memoria o reflexión)",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.plain)
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

    // ✅ FaceID/TouchID desactivado por ahora (sin AppLock)
    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacidad")
                .font(.system(size: 18, weight: .bold, design: .serif))

            SettingsRowStatic(
                title: "Protección biométrica",
                subtitle: "Desactivada temporalmente (estabilizando la app).",
                systemImage: "lock.shield"
            )

            Divider().opacity(0.4)

            Text("Tus datos se guardan localmente en el dispositivo.")
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

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exportación")
                .font(.system(size: 18, weight: .bold, design: .serif))

            NavigationLink {
                ExportView(entries: entries)
            } label: {
                SettingsRow(
                    title: "Exportar (MD / PDF)",
                    subtitle: "Genera archivos y compártelos",
                    systemImage: "square.and.arrow.up"
                )
            }
            .buttonStyle(.plain)
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

    // ✅ NUEVO: Acerca de con texto editorial (5–6 líneas)
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Acerca de")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                Spacer()
                Text(appVersionString)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Versión \(appVersionString)")
            }

            aboutTextBlock

            Divider().opacity(0.35)

            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 24)
                    .foregroundStyle(.secondary)

                Text("Desarrollada por Javier Benítez Láinez.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
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
        .accessibilityElement(children: .contain)
    }

    private var aboutTextBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Registro2026 es un cuaderno digital para escribir sin ruido.")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(.primary)

            Text("No analiza, no puntúa, no interpreta.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Está pensado como una respuesta suave al brain slop: la saturación de estímulos que cierra el pensamiento antes de tiempo.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Aquí escribir es una pausa. Cerrar con una pregunta es una forma de volver.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }
}

// MARK: - Reusable rows

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.secondary)
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

private struct SettingsRowStatic: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(subtitle)
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
}

