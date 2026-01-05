//
//  FocusSound.swift
//  Registro2026
//
//  Created by Javier Benitez on 5/1/26.
//

import AudioToolbox

enum FocusSound {
    static func click() {
        AudioServicesPlaySystemSound(1104) // click suave
    }
}

