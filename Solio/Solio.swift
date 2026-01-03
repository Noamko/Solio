//
//  Solio.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

@main
struct Solio: App {
    
    init() {
        // Pre-warm managers in background - they'll load asynchronously
        _ = AudioManager.shared
        _ = StatsManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
