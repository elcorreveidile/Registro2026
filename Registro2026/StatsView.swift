//
//  StatsView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \Entry.date, order: .reverse)
    private var entries: [Entry]

    private var calendar: Calendar { Calendar.current }

    private var uniqueDays: [Date] {
        let days = entries.map { calendar.startOfDay(for: $0.date) }
        let set = Set(days)
        return set.sorted()
    }

    private var totalDaysWritten: Int {
        uniqueDays.count
    }

    private var thisMonthDaysWritten: Int {
        let now = Date()
        return uniqueDays.filter { calendar.isDate($0, equalTo: now, toGranularity: .month) }.count
    }

    private var currentStreak: Int {
        guard !uniqueDays.isEmpty else { return 0 }
        var streak = 0
        var day = calendar.startOfDay(for: .now)

        while uniqueDays.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    private var maxStreak: Int {
        let sorted = uniqueDays
        guard !sorted.isEmpty else { return 0 }

        var best = 1
        var run = 1

        for i in 1..<sorted.count {
            let prev = sorted[i-1]
            let cur = sorted[i]
            let diff = calendar.dateComponents([.day], from: prev, to: cur).day ?? 0
            if diff == 1 {
                run += 1
                best = max(best, run)
            } else {
                run = 1
            }
        }
        return best
    }

    var body: some View {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        StatHeader()

                        StatCard(title: "Días escritos (año)", value: "\(totalDaysWritten)", systemImage: "calendar.badge.checkmark")
                        StatCard(title: "Días escritos (mes)", value: "\(thisMonthDaysWritten)", systemImage: "calendar")
                        StatCard(title: "Racha actual", value: "\(currentStreak)", systemImage: "flame")
                        StatCard(title: "Racha máxima", value: "\(maxStreak)", systemImage: "trophy")

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }


private struct StatHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tu año en números")
                .font(.system(size: 26, weight: .bold, design: .serif))
            Text("Sin juicio. Solo trazas.")
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
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color("AppBackground")))
                .overlay(Circle().stroke(Color("CardBorder"), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .serif))
            }

            Spacer()
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

