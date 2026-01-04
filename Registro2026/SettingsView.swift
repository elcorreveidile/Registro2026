//
//  SettingsView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("lock_enabled") private var lockEnabled: Bool = false
    @AppStorage("daily_reminder_enabled") private var dailyReminderEnabled: Bool = false
    @AppStorage("editorial_theme_enabled") private var editorialThemeEnabled: Bool = true

    var body: some View {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                List {
                    Section("Apariencia") {
                        Toggle("Tema editorial (papel)", isOn: $editorialThemeEnabled)
                        Text("En esta versión el tema se aplica con los colores de Assets.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("Privacidad") {
                        Toggle("Bloqueo con Face ID (próxima versión)", isOn: $lockEnabled)
                        Text("La app es 100% local: no hay cuentas y no se recopilan datos.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("Recordatorios") {
                        Toggle("Recordatorio diario (próxima versión)", isOn: $dailyReminderEnabled)
                        Text("Para App Store, los recordatorios son una función muy vendible.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("Exportación") {
                        Text("Exporta desde la pestaña “Hoy” → icono de compartir.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("Créditos") {
                        Text("Registro 2026")
                            .font(.body)
                        Text("Versión 1.0")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color("AppBackground"))
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }


