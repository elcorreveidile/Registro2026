//
//  CoverStore.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI

@MainActor
final class CoverStore: ObservableObject {

    // Imagen que usa la app (Header, preview, etc.)
    @Published private(set) var coverUIImage: UIImage? = nil

    // ✅ Mejor como propiedad calculada (siempre coherente)
    var hasCustomCover: Bool { coverUIImage != nil }

    // Clave donde guardamos SOLO el nombre del archivo
    private let filenameKey = "coverImageFilename"

    // Carpeta propia de la app
    private let folderName = "Registro2026"

    init() {
        load()
    }

    // MARK: - API pública

    /// Guarda una nueva portada
    func setCover(from imageData: Data) throws {
        guard let rawImage = UIImage(data: imageData) else {
            throw StoreError.invalidImageData
        }

        // Reducimos tamaño para que no sea enorme
        let processedImage = rawImage.resized(maxSide: 2400) ?? rawImage

        guard let jpegData = processedImage.jpegData(compressionQuality: 0.85) else {
            throw StoreError.writeFailed
        }

        try ensureDirectory()

        let oldFilename = UserDefaults.standard.string(forKey: filenameKey)

        let newFilename = "cover_\(UUID().uuidString).jpg"
        let newURL = try fileURL(for: newFilename)

        // ✅ Escritura atómica (segura)
        try jpegData.write(to: newURL, options: [.atomic])

        // ✅ Excluir del backup (buena práctica para assets regenerables)
        try? excludeFromBackup(newURL)

        // Guardamos el nombre nuevo
        UserDefaults.standard.set(newFilename, forKey: filenameKey)

        // Borramos el archivo anterior si existía (sin reventar si no está)
        if let oldFilename, let oldURL = try? fileURL(for: oldFilename) {
            try? FileManager.default.removeItem(at: oldURL)
        }

        // Actualizamos imagen en memoria
        coverUIImage = processedImage
    }

    /// Borra la portada personalizada
    func clear() {
        if let filename = UserDefaults.standard.string(forKey: filenameKey),
           let url = try? fileURL(for: filename) {
            try? FileManager.default.removeItem(at: url)
        }

        UserDefaults.standard.removeObject(forKey: filenameKey)
        coverUIImage = nil
    }

    // MARK: - Carga inicial

    private func load() {
        guard let filename = UserDefaults.standard.string(forKey: filenameKey),
              let url = try? fileURL(for: filename),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            coverUIImage = nil
            return
        }

        coverUIImage = image
    }

    // MARK: - Rutas de archivos

    private func ensureDirectory() throws {
        let dir = try directoryURL()
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try? excludeFromBackup(dir)
        }
    }

    private func directoryURL() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(folderName, isDirectory: true)
    }

    private func fileURL(for filename: String) throws -> URL {
        try directoryURL().appendingPathComponent(filename)
    }

    private func excludeFromBackup(_ url: URL) throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = url
        try mutableURL.setResourceValues(values)
    }

    // MARK: - Errores

    enum StoreError: LocalizedError {
        case invalidImageData
        case writeFailed

        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "La imagen no se pudo leer."
            case .writeFailed:
                return "No se pudo guardar la imagen."
            }
        }
    }
}

// MARK: - Helper para reducir imágenes

private extension UIImage {
    func resized(maxSide: CGFloat) -> UIImage? {
        let maxCurrentSide = max(size.width, size.height)
        guard maxCurrentSide > maxSide else { return self }

        let scale = maxSide / maxCurrentSide
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

