//
//  AppLock.swift
//  Registro2026
//
//  Created by Javier Benitez on 4/1/26.
//

import SwiftUI
import LocalAuthentication

@MainActor
final class AppLock: ObservableObject {
    // Ajuste persistente
    @AppStorage("lock_enabled") var isEnabled: Bool = false

    // Estado runtime
    @Published var isUnlocked: Bool = true
    @Published var lastAuthError: String? = nil

    func configureInitialState() {
        // Si está activado, arrancamos bloqueados
        isUnlocked = !isEnabled
    }

    func lock() {
        guard isEnabled else {
            isUnlocked = true
            return
        }
        isUnlocked = false
    }

    func unlockWithBiometrics() {
        guard isEnabled else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        guard canEvaluate else {
            // Si no hay biometría configurada, lo dejamos bloqueado y explicamos.
            lastAuthError = "No hay Face ID/Touch ID disponible o no está configurado en este dispositivo."
            isUnlocked = false
            return
        }

        let reason = "Desbloquear Registro 2026"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, evalError in
            Task { @MainActor in
                guard let self else { return }
                if success {
                    self.lastAuthError = nil
                    self.isUnlocked = true
                } else {
                    self.isUnlocked = false
                    if let evalError {
                        self.lastAuthError = (evalError as NSError).localizedDescription
                    } else {
                        self.lastAuthError = "No se pudo verificar la identidad."
                    }
                }
            }
        }
    }

    func biometricsType() -> BiometricKind {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .none
        }
    }

    enum BiometricKind {
        case faceID, touchID, none

        var title: String {
            switch self {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .none: return "Biometría"
            }
        }
    }
}

// MARK: - Pantalla de bloqueo (editorial)

struct LockScreenView: View {
    @EnvironmentObject private var appLock: AppLock

    var body: some View {
        ZStack {
            // Fondo editorial
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: appLock.biometricsType() == .touchID ? "touchid" : "faceid")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.secondary)

                    Text("Registro 2026")
                        .font(.system(size: 34, weight: .bold, design: .serif))

                    Text("Privado. Íntimo. Tu año, por escrito.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if let msg = appLock.lastAuthError {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 2)
                }

                Button {
                    appLock.unlockWithBiometrics()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Desbloquear con \(appLock.biometricsType().title)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.black.opacity(0.80))
                    )
                }
                .padding(.horizontal, 22)
                .padding(.top, 6)

                Spacer()
            }
        }
    }
}

