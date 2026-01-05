import SwiftUI

@MainActor
final class CoverImageStore: ObservableObject {

    enum StoreError: LocalizedError {
        case invalidImageData
        case cannotCreateDirectory
        case writeFailed
        case readFailed

        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "La imagen no se pudo leer."
            case .cannotCreateDirectory:
                return "No se pudo preparar el almacenamiento local."
            case .writeFailed:
                return "No se pudo guardar la portada."
            case .readFailed:
                return "No se pudo cargar la portada."
            }
        }
    }

    // Guardamos solo el nombre del fichero en UserDefaults
    private let defaultsKey = "coverImageFilename"

    // Carpeta propia de la app dentro de Application Support
    private let folderName = "Registro2026"

    @Published private(set) var coverImage: UIImage? = nil
    @Published private(set) var hasCustomCover: Bool = false

    init() {
        reload()
    }

    /// Recarga la portada desde disco (si existe)
    func reload() {
        let filename = UserDefaults.standard.string(forKey: defaultsKey)

        guard let filename else {
            coverImage = nil
            hasCustomCover = false
            return
        }

        do {
            let url = try fileURL(for: filename)
            let data = try Data(contentsOf: url)

            guard let img = UIImage(data: data) else {
                throw StoreError.readFailed
            }

            coverImage = img
            hasCustomCover = true

        } catch {
            // Si algo falla, limpiamos para no quedar “rotos”
            UserDefaults.standard.removeObject(forKey: defaultsKey)
            coverImage = nil
            hasCustomCover = false
        }
    }

    /// Guarda una nueva portada, y borra la anterior si existía
    func setCover(from imageData: Data) throws {
        guard let raw = UIImage(data: imageData) else {
            throw StoreError.invalidImageData
        }

        // 1) Reescalar para que no sea enorme (mejora rendimiento)
        let processed = raw.preparingCover(maxDimension: 2400) ?? raw

        // 2) Pasar a JPEG
        guard let jpeg = processed.jpegData(compressionQuality: 0.85) else {
            throw StoreError.writeFailed
        }

        // 3) Guardar nueva
        try ensureDirectory()

        let oldFilename = UserDefaults.standard.string(forKey: defaultsKey)
        let newFilename = "cover_\(UUID().uuidString).jpg"
        let newURL = try fileURL(for: newFilename)

        do {
            try jpeg.write(to: newURL, options: [.atomic])
        } catch {
            throw StoreError.writeFailed
        }

        // 4) Guardar el nombre en defaults
        UserDefaults.standard.set(newFilename, forKey: defaultsKey)

        // 5) Borrar el archivo anterior (si existía)
        if let oldFilename {
            do {
                let oldURL = try fileURL(for: oldFilename)
                try? FileManager.default.removeItem(at: oldURL)
            } catch {
                // Si falla el borrado, no pasa nada grave.
                // Ya tienes la nueva portada.
            }
        }

        // 6) Actualizar estado para que la UI se refresque
        coverImage = processed
        hasCustomCover = true
    }

    /// Restablece: borra la portada personalizada y vuelve al default
    func resetCover() {
        let oldFilename = UserDefaults.standard.string(forKey: defaultsKey)

        UserDefaults.standard.removeObject(forKey: defaultsKey)

        if let oldFilename {
            do {
                let oldURL = try fileURL(for: oldFilename)
                try? FileManager.default.removeItem(at: oldURL)
            } catch {
                // no-op
            }
        }

        coverImage = nil
        hasCustomCover = false
    }

    // MARK: - Rutas

    private func ensureDirectory() throws {
        let dir = try directoryURL()
        if !FileManager.default.fileExists(atPath: dir.path) {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            } catch {
                throw StoreError.cannotCreateDirectory
            }
        }
    }

    private func directoryURL() throws -> URL {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw StoreError.cannotCreateDirectory
        }
        return base.appendingPathComponent(folderName, isDirectory: true)
    }

    private func fileURL(for filename: String) throws -> URL {
        try directoryURL().appendingPathComponent(filename, isDirectory: false)
    }
}

// MARK: - Helper para reescalar imágenes

private extension UIImage {

    func preparingCover(maxDimension: CGFloat) -> UIImage? {
        let w = size.width
        let h = size.height
        guard w > 0, h > 0 else { return nil }

        let maxSide = max(w, h)
        guard maxSide > maxDimension else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: w * scale, height: h * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

