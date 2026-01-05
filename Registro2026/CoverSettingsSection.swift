//
//  CoverSettingsSection.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import PhotosUI

struct CoverSettingsSection: View {

    @EnvironmentObject private var coverStore: CoverStore

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        Section("Portada") {

            CoverPreviewCard(
                image: coverStore.coverUIImage,
                hasCustom: coverStore.hasCustomCover
            )

            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                Label("Elegir foto", systemImage: "photo")
            }

            if coverStore.hasCustomCover {
                Button(role: .destructive) {
                    coverStore.clear()
                } label: {
                    Label("Restablecer portada", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .onChange(of: pickerItem) { _, newValue in
            guard let newValue else { return }

            Task {
                do {
                    // Intentamos leer la imagen seleccionada como Data
                    guard let data = try await newValue.loadTransferable(type: Data.self) else {
                        throw CoverStore.StoreError.invalidImageData
                    }

                    // Guardamos la portada usando el store (esto la persiste en disco)
                    try coverStore.setCover(from: data)

                } catch {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? "No se pudo usar esa imagen."
                    showError = true
                }

                // Limpiamos selección para poder elegir otra después sin problemas
                pickerItem = nil
            }
        }
        .alert("Portada", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

private struct CoverPreviewCard: View {
    let image: UIImage?
    let hasCustom: Bool

    var body: some View {
        ZStack {
            // Fondo: personalizada > asset > gradiente
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let asset = UIImage(named: "HeaderImage") {
                Image(uiImage: asset)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            // velo editorial para legibilidad (siempre)
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.10)],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Registro de vida · 2026")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                Text(hasCustom ? "Portada personalizada" : "Portada por defecto")
                    .font(.footnote)
                    .opacity(0.9)
            }
            .foregroundStyle(.white)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(hasCustom ? "Portada personalizada" : "Portada por defecto")
    }
}

