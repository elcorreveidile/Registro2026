//
//  CalendarView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    @State private var monthOffset: Int = 0
    @State private var selectedEntry: Entry? = nil

    private var calendar: Calendar { Calendar.current }

    private var monthDate: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: calendar.startOfDay(for: .now)) ?? .now
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: monthDate).capitalized
    }

    private func startOfMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private var daysInMonth: [Date] {
        let start = startOfMonth(monthDate)
        let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<2
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
    }

    private var leadingBlankDays: Int {
        let start = startOfMonth(monthDate)
        let weekday = calendar.component(.weekday, from: start)
        // Convertimos (domingo=1...sábado=7) a (lunes=0...domingo=6)
        return (weekday + 5) % 7
    }

    private func entryForDay(_ date: Date) -> Entry? {
        let d = calendar.startOfDay(for: date)
        return entries.first(where: { calendar.isDate($0.date, inSameDayAs: d) })
    }

    private func openOrCreateEntry(for day: Date) {
        let target = calendar.startOfDay(for: day)

        if let existing = entryForDay(target) {
            selectedEntry = existing
            return
        }

        let newEntry = Entry(date: target)
        context.insert(newEntry)
        selectedEntry = newEntry
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 12) {
                header
                weekdayRow
                grid
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .navigationTitle("Calendario")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedEntry) { entry in
            EntryEditor(entry: entry)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                monthOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(Circle().fill(Color("CardBackground")))
                    .overlay(Circle().stroke(Color("CardBorder"), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(monthTitle)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                Text("Toca un día para abrir o crear su entrada")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                monthOffset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(Circle().fill(Color("CardBackground")))
                    .overlay(Circle().stroke(Color("CardBorder"), lineWidth: 1))
            }
        }
    }

    private var weekdayRow: some View {
        let days = ["L", "M", "X", "J", "V", "S", "D"]
        return HStack {
            ForEach(days, id: \.self) { d in
                Text(d)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    private var grid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<leadingBlankDays, id: \.self) { _ in
                Color.clear.frame(height: 44)
            }

            ForEach(daysInMonth, id: \.self) { day in
                let hasEntry = entryForDay(day) != nil

                CalendarDayCell(date: day, hasEntry: hasEntry) {
                    openOrCreateEntry(for: day)
                }
            }
        }
        .padding(.top, 4)
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
}

private struct CalendarDayCell: View {
    let date: Date
    let hasEntry: Bool
    let onTap: () -> Void

    private var dayNumber: String {
        String(Calendar.current.component(.day, from: date))
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayNumber)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Circle()
                .fill(hasEntry ? Color.primary.opacity(0.60) : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color("CardBorder"), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

