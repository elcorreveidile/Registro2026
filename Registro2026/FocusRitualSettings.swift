//
//  FocusRitualSettings.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import Foundation

/// Ajustes del ritual de cierre (persistidos con UserDefaults vía AppStorage).
enum FocusRitualStyle: String, CaseIterable, Identifiable {
    case mixed
    case memory
    case reflection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mixed: return "Mixto"
        case .memory: return "Memoria"
        case .reflection: return "Reflexión"
        }
    }

    var subtitle: String {
        switch self {
        case .mixed: return "Mezcla memoria y pensamiento crítico"
        case .memory: return "Solo preguntas íntimas de cierre"
        case .reflection: return "Solo preguntas de pausa y criterio"
        }
    }
}

/// Claves de UserDefaults
enum FocusRitualKeys {
    static let isEnabled = "focusRitual.isEnabled"
    static let style = "focusRitual.style"
}

