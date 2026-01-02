//
//  NoteButtonsView.swift
//  DoremiFasolasi
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

struct NoteButtonsView: View {
    let onNoteTapped: (NoteName) -> Void
    let disabled: Bool
    let notation: NoteNotation
    
    private let notes: [NoteName] = NoteName.allCases
    
    var body: some View {
        VStack(spacing: 16) {
            // First row: Do Re Mi Fa (or C D E F)
            HStack(spacing: 12) {
                ForEach(notes.prefix(4), id: \.self) { note in
                    NoteButton(note: note, onTap: onNoteTapped, disabled: disabled, notation: notation)
                }
            }
            
            // Second row: Sol La Si (or G A B)
            HStack(spacing: 12) {
                ForEach(notes.suffix(3), id: \.self) { note in
                    NoteButton(note: note, onTap: onNoteTapped, disabled: disabled, notation: notation)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct NoteButton: View {
    let note: NoteName
    let onTap: (NoteName) -> Void
    let disabled: Bool
    let notation: NoteNotation
    
    @State private var isPressed = false
    
    private var buttonColor: Color {
        switch note {
        case .Do: return Color(red: 0.9, green: 0.3, blue: 0.3)   // Red
        case .Re: return Color(red: 0.95, green: 0.6, blue: 0.2)  // Orange
        case .Mi: return Color(red: 0.95, green: 0.85, blue: 0.3) // Yellow
        case .Fa: return Color(red: 0.4, green: 0.8, blue: 0.4)   // Green
        case .Sol: return Color(red: 0.3, green: 0.7, blue: 0.9)  // Cyan
        case .La: return Color(red: 0.4, green: 0.4, blue: 0.9)   // Blue
        case .Si: return Color(red: 0.7, green: 0.4, blue: 0.9)   // Purple
        }
    }
    
    var body: some View {
        Button {
            if !disabled {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                // Play the note sound
                AudioManager.shared.playNote(note)
                onTap(note)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
        } label: {
            Text(note.displayName(for: notation))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 70, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(buttonColor)
                        .shadow(color: buttonColor.opacity(0.5), radius: isPressed ? 2 : 6, y: isPressed ? 1 : 4)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0)
    }
}

#Preview {
    NoteButtonsView(onNoteTapped: { _ in }, disabled: false, notation: .solfege)
        .padding()
}

