//
//  ExportView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import PDFKit

struct ExportView: View {
    let entries: [Entry]

    @State private var scope: ExportScope = .all
    @State private var customFrom: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var customTo: Date = .now

    @State private var onlyWithContent: Bool = true
    @State private var includeTags: Bool = true

    @State private var mdURL: URL?
    @State private var pdfURL: URL?
    @State private var lastError: String?

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Rango", selection: $scope) {
                            ForEach(ExportScope.allCases, id: \.self) { s in
                                Text(s.title).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)

                        if scope == .custom {
                            VStack(spacing: 10) {
                                DatePicker("Desde", selection: $customFrom, displayedComponents: .date)
                                DatePicker("Hasta", selection: $customTo, displayedComponents: .date)
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }

                        Toggle("Solo entradas con contenido", isOn: $onlyWithContent)
                        Toggle("Incluir etiquetas", isOn: $includeTags)

                        Divider().opacity(0.4)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Vista previa")
                                .font(.system(size: 18, weight: .bold, design: .serif))

                            Text(previewText)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        if let lastError {
                            Text(lastError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding(.top, 4)
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
                    .padding(.horizontal)

                    actions
                        .padding(.horizontal)
                        .padding(.bottom, 22)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Exportar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Genera por primera vez para que ya haya links listos
            generateFiles()
        }
        .onChange(of: scope) { _, _ in generateFiles() }
        .onChange(of: customFrom) { _, _ in generateFiles() }
        .onChange(of: customTo) { _, _ in generateFiles() }
        .onChange(of: onlyWithContent) { _, _ in generateFiles() }
        .onChange(of: includeTags) { _, _ in generateFiles() }
    }

    // MARK: - UI bits

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exportación editorial")
                .font(.system(size: 28, weight: .bold, design: .serif))
            Text("Genera un archivo Markdown y un PDF listos para archivo, lectura o impresión.")
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

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                generateFiles()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .bold))
                    Text("Regenerar archivos")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.primary)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color("CardBackground"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color("CardBorder"), lineWidth: 1)
                )
            }

            HStack(spacing: 10) {
                if let mdURL {
                    ShareLink(item: mdURL) {
                        labelChip(title: "Compartir MD", systemImage: "doc.plaintext")
                    }
                } else {
                    labelChip(title: "MD no listo", systemImage: "doc.plaintext")
                        .opacity(0.5)
                }

                if let pdfURL {
                    ShareLink(item: pdfURL) {
                        labelChip(title: "Compartir PDF", systemImage: "doc.richtext")
                    }
                } else {
                    labelChip(title: "PDF no listo", systemImage: "doc.richtext")
                        .opacity(0.5)
                }
            }
        }
    }

    private func labelChip(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.75))
        )
    }

    // MARK: - Data

    private var selectedEntries: [Entry] {
        let cal = Calendar.current
        let base = entries.sorted { $0.date < $1.date }

        let filteredByDate: [Entry] = {
            switch scope {
            case .all:
                return base
            case .last7:
                let from = cal.date(byAdding: .day, value: -7, to: .now) ?? .distantPast
                return base.filter { $0.date >= cal.startOfDay(for: from) }
            case .last30:
                let from = cal.date(byAdding: .day, value: -30, to: .now) ?? .distantPast
                return base.filter { $0.date >= cal.startOfDay(for: from) }
            case .custom:
                let a = cal.startOfDay(for: customFrom)
                let b = cal.startOfDay(for: customTo)
                let lo = min(a, b)
                let hi = max(a, b)
                // incluimos el día "hi" completo
                let hiPlus = cal.date(byAdding: .day, value: 1, to: hi) ?? hi
                return base.filter { $0.date >= lo && $0.date < hiPlus }
            }
        }()

        if !onlyWithContent { return filteredByDate }

        return filteredByDate.filter { e in
            let hasText =
            !e.done.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !e.thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !e.consumed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !e.work.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !e.mood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !e.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

            let hasTags = !e.tags.isEmpty
            return hasText || (includeTags && hasTags)
        }
    }

    private var previewText: String {
        let count = selectedEntries.count
        let rangeTitle = scope.preview(from: customFrom, to: customTo)
        return "\(count) entradas · \(rangeTitle)"
    }

    // MARK: - Generate files

    private func generateFiles() {
        lastError = nil

        let items = selectedEntries
        let title = "Registro 2026"
        let subtitle = scope.preview(from: customFrom, to: customTo)

        // Markdown
        do {
            let md = ExportComposer.markdown(title: title, subtitle: subtitle, entries: items, includeTags: includeTags)
            let url = try ExportComposer.writeTempFile(named: ExportComposer.safeFilename("Registro2026-\(subtitle).md"), contents: md)
            mdURL = url
        } catch {
            mdURL = nil
            lastError = "No se pudo generar el Markdown: \(error.localizedDescription)"
        }

        // PDF
        do {
            let url = try ExportComposer.makePDFTempFile(
                named: ExportComposer.safeFilename("Registro2026-\(subtitle).pdf"),
                title: title,
                subtitle: subtitle,
                entries: items,
                includeTags: includeTags
            )
            pdfURL = url
        } catch {
            pdfURL = nil
            lastError = "No se pudo generar el PDF: \(error.localizedDescription)"
        }
    }
}

// MARK: - Scope

private enum ExportScope: CaseIterable {
    case all, last7, last30, custom

    var title: String {
        switch self {
        case .all: return "Todo"
        case .last7: return "7 días"
        case .last30: return "30 días"
        case .custom: return "Fechas"
        }
    }

    func preview(from: Date, to: Date) -> String {
        switch self {
        case .all:
            return "Todo"
        case .last7:
            return "Últimos 7 días"
        case .last30:
            return "Últimos 30 días"
        case .custom:
            return "\(SpanishDate.short(from)) → \(SpanishDate.short(to))"
        }
    }
}

// MARK: - Composer

private enum ExportComposer {

    // MARK: Markdown

    static func markdown(title: String, subtitle: String, entries: [Entry], includeTags: Bool) -> String {
        var out: [String] = []
        out.append("# \(title)")
        out.append("")
        out.append("_\(subtitle)_")
        out.append("")
        out.append("---")
        out.append("")

        for e in entries {
            out.append("## \(SpanishDate.long(e.date))")
            out.append("")

            if includeTags, !e.tags.isEmpty {
                let tags = e.tags.map(\.name).sorted().map { "#\($0)" }.joined(separator: " ")
                out.append("**Etiquetas:** \(tags)")
                out.append("")
            }

            appendField("Hecho", e.done, to: &out)
            appendField("Pensado", e.thought, to: &out)
            appendField("Leído / visto / escuchado", e.consumed, to: &out)
            appendField("Trabajo / creación", e.work, to: &out)
            appendField("Estado de ánimo", e.mood, to: &out)
            appendField("Nota", e.note, to: &out)

            out.append("")
            out.append("---")
            out.append("")
        }

        return out.joined(separator: "\n")
    }

    private static func appendField(_ label: String, _ value: String, to out: inout [String]) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return }
        out.append("**\(label):** \(v)")
        out.append("")
    }

    // MARK: Temp files

    static func writeTempFile(named: String, contents: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(named)
        try contents.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    static func safeFilename(_ name: String) -> String {
        let bad = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleaned = name.components(separatedBy: bad).joined(separator: "-")
        return cleaned.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: PDF

    static func makePDFTempFile(named: String,
                                title: String,
                                subtitle: String,
                                entries: [Entry],
                                includeTags: Bool) throws -> URL {

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 aprox en puntos
        let margin: CGFloat = 54
        let contentRect = pageRect.insetBy(dx: margin, dy: margin)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(named)

        try renderer.writePDF(to: url) { ctx in
            var y = contentRect.minY

            func newPage() {
                ctx.beginPage()
                y = contentRect.minY
            }

            newPage()

            // Styles
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
            ]
            let subAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let h2Attr: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            let bodyAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            let labelAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            let tagAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]

            // Header
            y = drawText(title, in: contentRect, y: y, attributes: titleAttr, lineSpacing: 6)
            y = drawText(subtitle, in: contentRect, y: y, attributes: subAttr, lineSpacing: 10)

            y += 6
            y = drawRule(in: contentRect, y: y)
            y += 12

            for e in entries {
                // Date header
                let dateLine = SpanishDate.long(e.date)
                if y + 40 > contentRect.maxY { newPage() }
                y = drawText(dateLine, in: contentRect, y: y, attributes: h2Attr, lineSpacing: 8)

                if includeTags, !e.tags.isEmpty {
                    let tags = e.tags.map(\.name).sorted().map { "#\($0)" }.joined(separator: " ")
                    y = drawText(tags, in: contentRect, y: y, attributes: tagAttr, lineSpacing: 10)
                }

                y = drawField("Hecho", e.done, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)
                y = drawField("Pensado", e.thought, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)
                y = drawField("Leído / visto / escuchado", e.consumed, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)
                y = drawField("Trabajo / creación", e.work, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)
                y = drawField("Estado de ánimo", e.mood, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)
                y = drawField("Nota", e.note, in: contentRect, y: y, labelAttr: labelAttr, bodyAttr: bodyAttr)

                y += 6
                y = drawRule(in: contentRect, y: y)
                y += 12

                if y > contentRect.maxY - 40 {
                    newPage()
                }
            }
        }

        return url
    }

    private static func drawField(_ label: String,
                                  _ value: String,
                                  in rect: CGRect,
                                  y: CGFloat,
                                  labelAttr: [NSAttributedString.Key: Any],
                                  bodyAttr: [NSAttributedString.Key: Any]) -> CGFloat {
        var y = y
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return y }

        // Label
        y = drawText("\(label):", in: rect, y: y, attributes: labelAttr, lineSpacing: 2)
        // Body
        y = drawText(v, in: rect, y: y, attributes: bodyAttr, lineSpacing: 10)
        return y
    }

    private static func drawText(_ text: String,
                                 in rect: CGRect,
                                 y: CGFloat,
                                 attributes: [NSAttributedString.Key: Any],
                                 lineSpacing: CGFloat) -> CGFloat {
        let ns = text as NSString
        _ = CGRect(x: rect.minX, y: y, width: rect.width, height: rect.maxY - y)
        let bound = ns.boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                    attributes: attributes,
                                    context: nil)
        ns.draw(in: CGRect(x: rect.minX, y: y, width: rect.width, height: ceil(bound.height)), withAttributes: attributes)
        return y + ceil(bound.height) + lineSpacing
    }

    private static func drawRule(in rect: CGRect, y: CGFloat) -> CGFloat {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: y))
        path.addLine(to: CGPoint(x: rect.maxX, y: y))
        UIColor.separator.setStroke()
        path.lineWidth = 1
        path.stroke()
        return y
    }
}

