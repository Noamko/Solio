//
//  PianoKeysView.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

struct PianoKeysView: View {
    let onNoteTapped: (NoteName) -> Void
    let disabled: Bool
    
    // White keys in order: C, D, E, F, G, A, B
    private let whiteKeys: [NoteName] = [.Do, .Re, .Mi, .Fa, .Sol, .La, .Si]
    
    // Black keys positions (between white keys): C#, D#, skip, F#, G#, A#
    // Index represents position after which white key (0=C, 1=D, etc.)
    private let blackKeyPositions: [Int] = [0, 1, 3, 4, 5] // After C, D, F, G, A
    
    var body: some View {
        GeometryReader { geometry in
            let whiteKeyWidth = geometry.size.width / 7
            let whiteKeyHeight: CGFloat = 160
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = whiteKeyHeight * 0.6
            
            ZStack(alignment: .top) {
                // White keys
                HStack(spacing: 2) {
                    ForEach(whiteKeys, id: \.self) { note in
                        WhiteKeyView(
                            note: note,
                            width: whiteKeyWidth - 2,
                            height: whiteKeyHeight,
                            onTap: onNoteTapped,
                            disabled: disabled
                        )
                    }
                }
                
                // Black keys
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        if blackKeyPositions.contains(index) {
                            BlackKeyView(
                                width: blackKeyWidth,
                                height: blackKeyHeight
                            )
                            .offset(x: whiteKeyWidth * 0.5 - blackKeyWidth * 0.5)
                        }
                        
                        if index < 6 {
                            Spacer()
                                .frame(width: whiteKeyWidth + 2 - (blackKeyPositions.contains(index) ? blackKeyWidth : 0) - (blackKeyPositions.contains(index + 1) ? 0 : 0))
                        }
                    }
                }
                .frame(width: geometry.size.width)
            }
        }
        .frame(height: 160)
        .padding(.horizontal, 8)
    }
}

struct WhiteKeyView: View {
    let note: NoteName
    let width: CGFloat
    let height: CGFloat
    let onTap: (NoteName) -> Void
    let disabled: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            if !disabled {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                AudioManager.shared.playNote(note)
                onTap(note)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
        } label: {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: isPressed ? [Color(white: 0.85), Color(white: 0.9)] : [.white, Color(white: 0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: isPressed ? 1 : 3, y: isPressed ? 1 : 3)
                
                Text(note.letterName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.bottom, 12)
            }
            .frame(width: width, height: height)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.7 : 1.0)
    }
}

struct BlackKeyView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
    }
}

#Preview {
    PianoKeysView(onNoteTapped: { _ in }, disabled: false)
        .padding()
        .background(Color.gray.opacity(0.3))
}

