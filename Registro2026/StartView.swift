//
//  StartView.swift
//  Registro2026
//
//  Created by Javier Benitez on 3/1/26.
//

import SwiftUI

struct StartView: View {
    @State private var showMain = false
    @State private var autoCreateToday = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.35, blue: 0.95),
                    Color(red: 0.55, green: 0.20, blue: 0.90),
                    Color(red: 0.95, green: 0.40, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -220)

            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 420, height: 420)
                .blur(radius: 55)
                .offset(x: 160, y: 240)

            VStack(spacing: 18) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 92, height: 92)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(.white.opacity(0.22))
                        )

                    Image(systemName: "book.pages")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Registro 2026")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)

                Text("Tu año, por escrito. Sin ruido.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))

                Spacer()

                Button {
                    autoCreateToday = false
                    showMain = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Entrar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.black.opacity(0.22))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(.white.opacity(0.25))
                    )
                }
                .padding(.horizontal, 22)

                Button {
                    autoCreateToday = true
                    showMain = true
                } label: {
                    Text("Crear entrada de hoy y entrar")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.vertical, 12)
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 30)
        }
        // ✅ Presentación modal a pantalla completa: no hereda barras ocultas
        .fullScreenCover(isPresented: $showMain) {
            MainTabView(autoCreateTodayOnAppear: autoCreateToday)
        }
    }
}

