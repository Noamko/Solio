//
//  MusicStaffView.swift
//  DoremiFasolasi
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

struct MusicStaffView: View {
    let notes: [MusicNote]
    let clef: ClefType
    let currentNoteIndex: Int
    let showingFeedback: Bool
    let lastAnswerResult: AnswerResult
    
    // Dynamic sizing based on note count
    private var noteScale: CGFloat {
        switch notes.count {
        case 1...4: return 1.0
        case 5...8: return 0.85
        default: return 0.7
        }
    }
    
    private var lineSpacing: CGFloat {
        20 * noteScale
    }
    
    private var staffHeight: CGFloat {
        80 * noteScale
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let centerY = geometry.size.height / 2
            
            ZStack {
                // Staff lines
                StaffLinesView(centerY: centerY, width: width, lineSpacing: lineSpacing)
                
                // Clef
                ClefView(clef: clef, centerY: centerY, lineSpacing: lineSpacing)
                    .offset(x: -width/2 + 40 * noteScale + 10)
                
                // Notes
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    NoteView(
                        note: note,
                        isCurrentNote: index == currentNoteIndex,
                        isPastNote: index < currentNoteIndex,
                        showingFeedback: showingFeedback && index == currentNoteIndex,
                        answerResult: lastAnswerResult,
                        lineSpacing: lineSpacing
                    )
                    .offset(
                        x: noteXOffset(index: index, totalWidth: width),
                        y: -CGFloat(note.position) * (lineSpacing / 2)
                    )
                }
            }
        }
        .frame(height: 160 + 40 * noteScale)
    }
    
    private func noteXOffset(index: Int, totalWidth: CGFloat) -> CGFloat {
        let clefSpace: CGFloat = 60 * noteScale + 15
        let rightPadding: CGFloat = 20
        let availableWidth = totalWidth - clefSpace - rightPadding
        let startX = -totalWidth/2 + clefSpace
        let spacing = availableWidth / CGFloat(notes.count)
        return startX + (CGFloat(index) + 0.5) * spacing
    }
}

// MARK: - Staff Lines
struct StaffLinesView: View {
    let centerY: CGFloat
    let width: CGFloat
    let lineSpacing: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let linePositions = [-2, -1, 0, 1, 2]  // 5 lines centered on middle
            
            for pos in linePositions {
                let y = centerY + CGFloat(pos) * lineSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: 20, y: y))
                    p.addLine(to: CGPoint(x: width - 20, y: y))
                }
                context.stroke(path, with: .color(.primary), lineWidth: 2)
            }
        }
    }
}

// MARK: - Clef View
struct ClefView: View {
    let clef: ClefType
    let centerY: CGFloat
    let lineSpacing: CGFloat
    
    var body: some View {
        Group {
            if clef == .treble || clef == .random {
                // Use the musical symbol for treble clef
                Text("𝄞")
                    .font(.system(size: lineSpacing * 5.5))
                    .foregroundColor(.primary)
                    .offset(y: lineSpacing * 0.15)
            } else {
                Text("𝄢")
                    .font(.system(size: lineSpacing * 4))
                    .foregroundColor(.primary)
                    .offset(y: -lineSpacing * 0.5)
            }
        }
    }
}


// MARK: - Note View
struct NoteView: View {
    let note: MusicNote
    let isCurrentNote: Bool
    let isPastNote: Bool
    let showingFeedback: Bool
    let answerResult: AnswerResult
    let lineSpacing: CGFloat
    
    private var noteColor: Color {
        if showingFeedback {
            return answerResult == .correct ? .green : .red
        }
        if isPastNote {
            return .green.opacity(0.6)
        }
        if isCurrentNote {
            return .orange
        }
        return .primary
    }
    
    var body: some View {
        ZStack {
            // Ledger lines if needed
            LedgerLinesView(position: note.position, lineSpacing: lineSpacing)
            
            // Note head (oval)
            Ellipse()
                .fill(noteColor)
                .frame(width: lineSpacing * 1.4, height: lineSpacing * 1.0)
                .rotationEffect(.degrees(-15))
            
            // Note stem
            Rectangle()
                .fill(noteColor)
                .frame(width: 3, height: lineSpacing * 3)
                .offset(x: lineSpacing * 0.65, y: -lineSpacing * 1.5)
            
            // Feedback indicator
            if showingFeedback {
                Image(systemName: answerResult == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(answerResult == .correct ? .green : .red)
                    .offset(y: -lineSpacing * 2.5)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showingFeedback)
        .animation(.easeInOut(duration: 0.2), value: isPastNote)
    }
}

// MARK: - Ledger Lines
struct LedgerLinesView: View {
    let position: Int
    let lineSpacing: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let ledgerLineWidth: CGFloat = lineSpacing * 2
            
            // Ledger lines needed above the staff (position > 4)
            if position > 4 {
                for i in stride(from: 6, through: position, by: 2) {
                    let y = size.height/2 - CGFloat(i - position) * (lineSpacing / 2)
                    drawLedgerLine(context: context, y: y, width: ledgerLineWidth, centerX: size.width/2)
                }
            }
            
            // Ledger lines needed below the staff (position < -4)
            if position < -4 {
                for i in stride(from: -6, through: position, by: -2) {
                    let y = size.height/2 - CGFloat(i - position) * (lineSpacing / 2)
                    drawLedgerLine(context: context, y: y, width: ledgerLineWidth, centerX: size.width/2)
                }
            }
            
            // Middle C ledger line (position -6 for treble)
            if position == -6 || position == 6 {
                let y = size.height/2
                drawLedgerLine(context: context, y: y, width: ledgerLineWidth, centerX: size.width/2)
            }
        }
        .frame(width: lineSpacing * 3, height: lineSpacing * 4)
    }
    
    private func drawLedgerLine(context: GraphicsContext, y: CGFloat, width: CGFloat, centerX: CGFloat) {
        let path = Path { p in
            p.move(to: CGPoint(x: centerX - width/2, y: y))
            p.addLine(to: CGPoint(x: centerX + width/2, y: y))
        }
        context.stroke(path, with: .color(.primary), lineWidth: 2)
    }
}

#Preview {
    MusicStaffView(
        notes: [
            MusicNote(position: -3, noteName: .Fa),
            MusicNote(position: -1, noteName: .La),
            MusicNote(position: 1, noteName: .Do),
            MusicNote(position: 3, noteName: .Mi)
        ],
        clef: .treble,
        currentNoteIndex: 0,
        showingFeedback: false,
        lastAnswerResult: .pending
    )
    .padding()
}

