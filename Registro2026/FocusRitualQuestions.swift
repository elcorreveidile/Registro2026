//
//  FocusRitualQuestions.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import Foundation

/// Pool editorial de preguntas para el ritual de cierre.
/// La UI NO etiqueta categorías: solo selecciona el pool según Ajustes.
enum FocusRitualQuestions {

    // MARK: - Pools

    static let memory: [String] = [
        "¿Qué de lo escrito hoy quieres recordar mañana?",
        "¿Qué palabra se queda contigo?",
        "¿Qué frase no quieres perder?",
        "¿Qué ha quedado fuera de esta página?",
        "¿Qué te llevas de este momento?",
        "¿Ha sido suficiente por hoy?"
    ]

    static let reflection: [String] = [
        "¿De dónde viene esta idea?",
        "¿Qué emoción empuja primero a lo que has escrito?",
        "¿Qué parte suena demasiado segura?",
        "¿Cuál es la afirmación dura en una frase?",
        "¿Qué has evitado pensar al escribir esto?",
        "¿Esto es una idea o una reacción?"
    ]

    static let mixed: [String] = memory + reflection

    // MARK: - API

    static func random(style: FocusRitualStyle) -> String {
        let pool: [String]
        switch style {
        case .mixed: pool = mixed
        case .memory: pool = memory
        case .reflection: pool = reflection
        }
        return pool.randomElement() ?? "¿Qué palabra se queda contigo?"
    }
}

