//
//  AppIconView.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

/// App Icon Design - Use the preview to screenshot and export as 1024x1024 PNG
struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.1, blue: 0.4),
                            Color(red: 0.4, green: 0.15, blue: 0.5),
                            Color(red: 0.15, green: 0.1, blue: 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Decorative staff lines
            VStack(spacing: size * 0.05) {
                ForEach(0..<5, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: size * 0.012)
                }
            }
            .padding(.horizontal, size * 0.08)
            .offset(y: size * 0.05)
            
            // Treble clef
            Text("𝄞")
                .font(.system(size: size * 0.7))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.6, blue: 0.2),
                            Color(red: 1.0, green: 0.4, blue: 0.5),
                            Color(red: 0.9, green: 0.3, blue: 0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: size * 0.02, y: size * 0.01)
                .offset(x: -size * 0.05, y: size * 0.02)
            
            // Musical notes decoration
            Group {
                // Top right note
                Circle()
                    .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(x: size * 0.28, y: -size * 0.22)
                
                // Small note
                Circle()
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.95))
                    .frame(width: size * 0.07, height: size * 0.07)
                    .offset(x: size * 0.32, y: size * 0.15)
                
                // Bottom note
                Circle()
                    .fill(Color(red: 0.95, green: 0.8, blue: 0.3))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: -size * 0.3, y: size * 0.28)
            }
            .shadow(color: .black.opacity(0.2), radius: size * 0.01)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Export Preview
// Use this preview to take a screenshot for the app icon
#Preview("App Icon 1024x1024") {
    AppIconView(size: 512)
        .frame(width: 512, height: 512)
}

#Preview("App Icon Small") {
    AppIconView(size: 120)
        .frame(width: 120, height: 120)
}

