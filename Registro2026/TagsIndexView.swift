import SwiftUI
import SwiftData

struct TagsIndexView: View {
    @State private var searchText = ""

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    private var counts: [(name: String, count: Int)] {
        var dict: [String: Int] = [:]
        for e in entries {
            for t in e.tags {
                dict[t.name, default: 0] += 1
            }
        }

        let list = dict
            .map { (name: $0.key, count: $0.value) }
            .sorted { a, b in
                if a.count == b.count { return a.name < b.name }
                return a.count > b.count
            }

        guard !searchText.isEmpty else { return list }
        let q = searchText.lowercased()
        return list.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    TagsHeader()

                    if counts.isEmpty {
                        EmptyTagsCard()
                            .padding(.horizontal)
                            .padding(.top, 4)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(counts, id: \.name) { item in
                                NavigationLink {
                                    TagEntriesView(tagName: item.name)
                                } label: {
                                    TagRowCard(name: item.name, count: item.count)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 22)
                    }
                }
                .padding(.top, 12)
            }
            // ✅ Siempre activo en el índice
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar etiqueta…"
            )
        }
        .navigationTitle("Etiquetas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - UI

private struct TagsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Índice temático")
                .font(.system(size: 26, weight: .bold, design: .serif))
            Text("Toca una etiqueta para ver sus entradas.")
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
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 4)
        .padding(.horizontal)
    }
}

private struct TagRowCard: View {
    let name: String
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(name)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            Text("\(count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Capsule().fill(Color("AppBackground")))
                .overlay(Capsule().strokeBorder(Color("CardBorder"), lineWidth: 1))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 4)
    }
}

private struct EmptyTagsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "tag")
                    .font(.system(size: 18, weight: .bold))
                Text("Aún no hay etiquetas")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }

            Text("Añade etiquetas en tus entradas y aparecerán aquí como índice.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 4)
    }
}

