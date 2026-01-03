//
//  Models.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import Foundation

// MARK: - Game Mode
enum GameMode: String, CaseIterable {
    case practice = "Practice"
    case timedChallenge = "Timed"
    case streak = "Streak"
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .practice: return "Practice at your own pace"
        case .timedChallenge: return "How many in 60 seconds?"
        case .streak: return "Don't miss a single note!"
        }
    }
    
    var icon: String {
        switch self {
        case .practice: return "music.note"
        case .timedChallenge: return "timer"
        case .streak: return "flame.fill"
        }
    }
}

// MARK: - Note Input Style
enum NoteNotation: String, CaseIterable {
    case solfege = "Do Re Mi"
    case letter = "C D E"
    case piano = "Piano"
    
    var displayName: String { rawValue }
}

// MARK: - Note Names (Solfège)
enum NoteName: String, CaseIterable {
    case Do = "Do"
    case Re = "Re"
    case Mi = "Mi"
    case Fa = "Fa"
    case Sol = "Sol"
    case La = "La"
    case Si = "Si"
    
    // Letter notation equivalent
    var letterName: String {
        switch self {
        case .Do: return "C"
        case .Re: return "D"
        case .Mi: return "E"
        case .Fa: return "F"
        case .Sol: return "G"
        case .La: return "A"
        case .Si: return "B"
        }
    }
    
    // Get display name based on notation style
    func displayName(for notation: NoteNotation) -> String {
        switch notation {
        case .solfege: return rawValue
        case .letter, .piano: return letterName
        }
    }
    
    // Position on staff relative to middle line (B4 for treble, D3 for bass)
    // Each step is a half-line (so 2 = one full line)
    var treblePosition: Int {
        switch self {
        case .Do: return -6  // C4 (middle C, below staff)
        case .Re: return -5  // D4
        case .Mi: return -4  // E4
        case .Fa: return -3  // F4
        case .Sol: return -2 // G4
        case .La: return -1  // A4
        case .Si: return 0   // B4 (middle line)
        }
    }
}

// MARK: - Clef Type
enum ClefType: String, CaseIterable {
    case treble = "Treble (Sol)"
    case bass = "Bass (Fa)"
    case random = "Random"
    
    var displayName: String { rawValue }
}

// MARK: - Difficulty Level
enum Difficulty: Int, CaseIterable {
    case beginner = 1
    case easy = 2
    case medium = 3
    case hard = 4
    case expert = 5
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Notes on staff lines only"
        case .easy: return "Notes on lines and spaces"
        case .medium: return "Includes 1 ledger line"
        case .hard: return "Includes 2 ledger lines"
        case .expert: return "Full range with 3 ledger lines"
        }
    }
    
    // Range of positions from center (in half-steps)
    // Positive = above, Negative = below
    var noteRange: ClosedRange<Int> {
        switch self {
        case .beginner: return -4...4   // Staff lines only
        case .easy: return -5...5       // Lines and spaces
        case .medium: return -7...7     // +1 ledger line
        case .hard: return -9...9       // +2 ledger lines
        case .expert: return -11...11   // +3 ledger lines
        }
    }
}

// MARK: - Music Note
struct MusicNote: Identifiable, Equatable {
    let id = UUID()
    let position: Int      // Position on staff (0 = middle line, positive = up, negative = down)
    let noteName: NoteName // The solfège name
    
    static func == (lhs: MusicNote, rhs: MusicNote) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Note Generator
struct NoteGenerator {
    
    /// Generate a random note within the difficulty range, optionally filtered by allowed notes
    static func generateNote(difficulty: Difficulty, clef: ClefType, allowedNotes: Set<NoteName>? = nil) -> MusicNote {
        let range = difficulty.noteRange
        
        // If we have allowed notes filter, find positions that match
        if let allowed = allowedNotes, !allowed.isEmpty {
            // Find all valid positions within range that produce allowed notes
            var validPositions: [Int] = []
            for pos in range {
                let note = noteNameForPosition(pos, clef: clef)
                if allowed.contains(note) {
                    validPositions.append(pos)
                }
            }
            
            // If we found valid positions, pick one randomly
            if !validPositions.isEmpty {
                let position = validPositions.randomElement()!
                let noteName = noteNameForPosition(position, clef: clef)
                return MusicNote(position: position, noteName: noteName)
            }
        }
        
        // Default behavior: any note in range
        let position = Int.random(in: range)
        let noteName = noteNameForPosition(position, clef: clef)
        return MusicNote(position: position, noteName: noteName)
    }
    
    /// Generate notes for a round
    static func generateNotes(count: Int = 4, difficulty: Difficulty, clef: ClefType, allowedNotes: Set<NoteName>? = nil) -> [MusicNote] {
        (0..<count).map { _ in generateNote(difficulty: difficulty, clef: clef, allowedNotes: allowedNotes) }
    }
    
    /// Convert staff position to note name
    static func noteNameForPosition(_ position: Int, clef: ClefType) -> NoteName {
        // For treble clef: middle line (position 0) = B4
        // For bass clef: middle line (position 0) = D3
        // Each position is a scale step
        
        let allNotes: [NoteName] = [.Do, .Re, .Mi, .Fa, .Sol, .La, .Si]
        
        // Treble clef: position 0 = B (Si), going up: C, D, E, F, G, A, B...
        // Bass clef: position 0 = D (Re), going up: E, F, G, A, B, C, D...
        
        let baseIndex: Int
        switch clef {
        case .treble, .random:
            baseIndex = 6 // Si (B) is at index 6
        case .bass:
            baseIndex = 1 // Re (D) is at index 1
        }
        
        // Calculate the note index, wrapping around
        var noteIndex = (baseIndex + position) % 7
        if noteIndex < 0 {
            noteIndex += 7
        }
        
        return allNotes[noteIndex]
    }
}

// MARK: - Answer Result
enum AnswerResult {
    case correct
    case incorrect
    case pending
}

// MARK: - Round Length
enum RoundLength: Int, CaseIterable {
    case short = 4
    case medium = 8
    case long = 12
    
    var displayName: String {
        "\(rawValue) notes"
    }
}

// MARK: - Metronome Speed
enum MetronomeSpeed: Int, CaseIterable {
    case slow = 60
    case moderate = 90
    case medium = 120
    case fast = 150
    
    var displayName: String {
        "\(rawValue) BPM"
    }
    
    var interval: TimeInterval {
        60.0 / Double(rawValue)
    }
}

