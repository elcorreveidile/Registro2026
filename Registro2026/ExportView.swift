//
//  ExportView.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI
import PDFKit

struct ExportView: View {
    let entries: [Entry]
    @State private var mdURL: URL?
    @State private var pdfURL: URL?

    var body: some View {
        VStack(spacing: 14) {

            Button("Generar Markdown (.md)") {
                mdURL = makeMarkdownFile()
            }
            .buttonStyle(.borderedProminent)

            if let mdURL {
                ShareLink(item: mdURL) { Text("Compartir Markdown") }
            }

            Divider().padding(.vertical, 6)

            Button("Generar PDF (.pdf)") {
                pdfURL = makePDFFile()
            }
            .buttonStyle(.borderedProminent)

            if let pdfURL {
                ShareLink(item: pdfURL) { Text("Compartir PDF") }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Exportar")
    }

    // MARK: - Markdown

    private func makeMarkdownFile() -> URL? {
        let sorted = entries.sorted { $0.date < $1.date }
        var out = "# REGISTRO 2026\n\n"

        for e in sorted {
            out += "## \(e.date.formatted(date: .numeric, time: .omitted))\n\n"
            out += "— Hecho: \(e.done)\n"
            out += "— Pensado: \(e.thought)\n"
            out += "— Leído / visto / escuchado: \(e.consumed)\n"
            out += "— Trabajo / creación: \(e.work)\n"
            out += "— Estado de ánimo: \(e.mood)\n"
            out += "— Nota suelta: \(e.note)\n"
            if !e.tags.isEmpty {
                out += "\n" + e.tags.map { "#\($0.name)" }.joined(separator: " ") + "\n"
            }
            out += "\n---\n\n"
        }

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Registro_2026.md")

        do {
            try out.data(using: .utf8)?.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }

    // MARK: - PDF

    private func makePDFFile() -> URL? {
        let sorted = entries.sorted { $0.date < $1.date }

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 aprox en puntos
        let margin: CGFloat = 40
        let contentWidth = pageRect.width - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Registro_2026.pdf")

        do {
            try renderer.writePDF(to: fileURL, withActions: { ctx in
                var y = margin

                func newPage() {
                    ctx.beginPage()
                    y = margin
                }

                newPage()

                // Estilos
                let titleFont = UIFont.systemFont(ofSize: 22, weight: .bold)
                let h2Font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                let bodyFont = UIFont.systemFont(ofSize: 11, weight: .regular)
                let monoFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)

                func draw(_ string: String, font: UIFont, spacingAfter: CGFloat = 10) {
                    let para = NSMutableParagraphStyle()
                    para.lineBreakMode = .byWordWrapping

                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .paragraphStyle: para
                    ]

                    let attr = NSAttributedString(string: string, attributes: attrs)
                    let rect = CGRect(x: margin, y: y, width: contentWidth, height: 10_000)
                    let measured = attr.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

                    if y + measured.height > pageRect.height - margin {
                        newPage()
                    }

                    attr.draw(in: CGRect(x: margin, y: y, width: contentWidth, height: measured.height))
                    y += measured.height + spacingAfter
                }

                // Cabecera
                draw("REGISTRO 2026", font: titleFont, spacingAfter: 16)

                // Entradas
                for e in sorted {
                    let dateLine = e.date.formatted(date: .long, time: .omitted)
                    draw(dateLine, font: h2Font, spacingAfter: 8)

                    func line(_ label: String, _ value: String) {
                        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        draw("— \(label): \(value)", font: bodyFont, spacingAfter: 6)
                    }

                    line("Hecho", e.done)
                    line("Pensado", e.thought)
                    line("Leído / visto / escuchado", e.consumed)
                    line("Trabajo / creación", e.work)
                    line("Estado de ánimo", e.mood)
                    line("Nota suelta", e.note)

                    if !e.tags.isEmpty {
                        let tagLine = e.tags.map { "#\($0.name)" }.joined(separator: " ")
                        draw(tagLine, font: monoFont, spacingAfter: 12)
                    } else {
                        y += 8
                    }

                    // Separador
                    if y + 12 > pageRect.height - margin { newPage() }
                    let sepY = y
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: margin, y: sepY))
                    path.addLine(to: CGPoint(x: pageRect.width - margin, y: sepY))
                    UIColor.black.withAlphaComponent(0.12).setStroke()
                    path.lineWidth = 1
                    path.stroke()
                    y += 16
                }
            })
            return fileURL
        } catch {
            return nil
        }
    }
}
