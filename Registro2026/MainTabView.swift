//
//  MainTabView.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI

enum AppTab: Hashable {
    case hoy, calendario, etiquetas, estadisticas, ajustes
}

struct MainTabView: View {

    let autoCreateTodayOnAppear: Bool
    @State private var tab: AppTab = .hoy

    init(autoCreateTodayOnAppear: Bool = false) {
        self.autoCreateTodayOnAppear = autoCreateTodayOnAppear
    }

    var body: some View {
        TabView(selection: $tab) {

            // ✅ Cada tab con su NavigationStack: toolbars y destinos estables
            NavigationStack {
                ContentView(autoCreateTodayOnAppear: autoCreateTodayOnAppear)
            }
            .tag(AppTab.hoy)
            .tabItem {
                Image(systemName: "pencil.and.list.clipboard")
                Text("Hoy")
            }

            NavigationStack {
                CalendarView()
            }
            .tag(AppTab.calendario)
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendario")
            }

            NavigationStack {
                TagsIndexView()
            }
            .tag(AppTab.etiquetas)
            .tabItem {
                Image(systemName: "tag")
                Text("Etiquetas")
            }

            NavigationStack {
                StatsView()
            }
            .tag(AppTab.estadisticas)
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Estadísticas")
            }

            NavigationStack {
                SettingsView()
            }
            .tag(AppTab.ajustes)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Ajustes")
            }
        }
    }
}

