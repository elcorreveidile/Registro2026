//
//  FocusWriterView.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import SwiftUI
import SwiftData

struct FocusWriterView: View {

    @ObservedObject var session: FocusSession
    @Environment(\.dismiss) private var dismiss

    // Ajustes del ritual (persistidos)
    @AppStorage(FocusRitualKeys.isEnabled) private var ritualEnabled: Bool = true

    // Temporizador
    @State private var startDate = Date()
    @State private var elapsed: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum FocusDuration: Int, CaseIterable, Identifiable {
        case off = 0, five = 5, ten = 10, fifteen = 15
        var id: Int { rawValue }
        var label: String { self == .off ? "—" : "\(rawValue)" }
    }

    @State private var duration: FocusDuration = .off

    // Ritual
    @State private var showExitRitual = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "timer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("Escribiendo · \(formattedElapsed)")
                        .font(.system(.footnote, design: .serif))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Menu {
                        ForEach(FocusDuration.allCases) { d in
                            Button {
                                duration = d
                                startDate = Date()
                                elapsed = 0
                            } label: {
                                Text(d == .off ? "Sin temporizador" : "\(d.label) min")
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "hourglass")
                            Text(duration == .off ? "Libre" : "\(duration.label) min")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)

                Divider().opacity(0.35)

                FocusEntryEditor(entry: session.entry)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        FocusSound.click()

                        if ritualEnabled {
                            showExitRitual = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cerrar modo escritura")
                }

                ToolbarItem(placement: .principal) {
                    Text("Escritura")
                        .font(.system(.headline, design: .serif))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            FocusSound.click()
            startDate = Date()
            elapsed = 0
        }
        .onReceive(timer) { _ in
            elapsed = Date().timeIntervalSince(startDate)

            if duration != .off {
                let limit = TimeInterval(duration.rawValue * 60)
                if elapsed >= limit && Int(elapsed) == Int(limit) {
                    FocusSound.click()
                }
            }
        }
        .fullScreenCover(isPresented: $showExitRitual) {
            FocusExitRitualView(question: session.question) {
                FocusSound.click()
                showExitRitual = false
                dismiss()
            }
        }
    }

    private var formattedElapsed: String {
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

