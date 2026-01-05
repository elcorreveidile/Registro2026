//
//  SettingsView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct SettingsView: View {

    @EnvironmentObject private var coverStore: CoverStore

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    // Picker + errores
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    header

                    coverCard
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
        .alert("Portada", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: pickerItem) { _, newValue in
            guard let newValue else { return }

            Task {
                do {
                    guard let data = try await newValue.loadTransferable(type: Data.self) else {
                        throw CoverStore.StoreError.invalidImageData
                    }
                    try coverStore.setCover(from: data)
                } catch {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? "No se pudo usar esa imagen."
                    showError = true
                }
                pickerItem = nil
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ajustes")
                .font(.system(size: 28, weight: .bold, design: .serif))
            Text("Privacidad, portada, exportación y opciones.")
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

    // ✅ NUEVA CARD: Portada
    private var coverCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Portada")
                .font(.system(size: 18, weight: .bold, design: .serif))

            coverPreview
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(coverStore.hasCustomCover ? "Portada personalizada" : "Portada por defecto")

            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                SettingsRow(
                    title: "Elegir foto",
                    subtitle: "Desde tu galería",
                    systemImage: "photo"
                )
            }
            .buttonStyle(.plain)

            if coverStore.hasCustomCover {
                Button(role: .destructive) {
                    coverStore.clear()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Restablecer portada")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text("Volver a la portada por defecto")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "trash")
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
                .buttonStyle(.plain)
            }

            Divider().opacity(0.4)

            Text("La portada se guarda localmente en el dispositivo.")
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

    private var coverPreview: some View {
        ZStack(alignment: .bottomLeading) {
            coverBackground
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

            VStack(alignment: .leading, spacing: 6) {
                Text("Registro de vida · 2026")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(.white)

                Text(coverStore.hasCustomCover ? "Portada personalizada" : "Portada por defecto")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(14)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var coverBackground: some View {
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

    // ✅ FaceID/TouchID desactivado por ahora (sin AppLock)
    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacidad")
                .font(.system(size: 18, weight: .bold, design: .serif))

            SettingsRow(
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

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acerca de")
                .font(.system(size: 18, weight: .bold, design: .serif))

            SettingsRow(
                title: "Registro2026",
                subtitle: "Versión en desarrollo",
                systemImage: "info.circle"
            )
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

