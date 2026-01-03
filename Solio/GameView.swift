//
//  GameView.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    let gameMode: GameMode
    let notation: NoteNotation
    let roundLength: RoundLength
    	
    init(gameMode: GameMode = .practice, difficulty: Difficulty, clefSetting: ClefType, notation: NoteNotation, roundLength: RoundLength = .short, allowedNotes: Set<NoteName>? = nil, metronomeEnabled: Bool = false, metronomeSpeed: MetronomeSpeed = .moderate) {
        _viewModel = StateObject(wrappedValue: GameViewModel(
            gameMode: gameMode,
            difficulty: difficulty,
            clefSetting: clefSetting,
            roundLength: roundLength,
            allowedNotes: allowedNotes,
            metronomeEnabled: metronomeEnabled,
            metronomeSpeed: metronomeSpeed
        ))
        self.gameMode = gameMode
        self.notation = notation
        self.roundLength = roundLength
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header with stats
                GameHeaderView(viewModel: viewModel, gameMode: gameMode)
                
                Spacer()
                
                // Music staff
                MusicStaffView(
                    notes: viewModel.notes,
                    clef: viewModel.currentClef,
                    currentNoteIndex: viewModel.currentNoteIndex,
                    showingFeedback: viewModel.showingFeedback,
                    lastAnswerResult: viewModel.lastAnswerResult
                )
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Note indicator
                noteIndicator
                
                Spacer()
                
                // Note input (buttons or piano)
                noteInput
            }
            
            // Game Over overlay
            if viewModel.isGameOver {
                GameOverView(viewModel: viewModel, gameMode: gameMode, onPlayAgain: {
                    viewModel.resetGame()
                }, onExit: {
                    dismiss()
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.stopAllTimers()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Menu")
                    }
                    .foregroundColor(.orange)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.resetGame()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.orange)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // Force light mode for sheet music aesthetic
        .onAppear {
            StatsManager.shared.startSession()
            viewModel.startMetronomeIfNeeded()
            if gameMode == .timedChallenge {
                viewModel.startTimer()
            }
        }
        .onDisappear {
            viewModel.stopAllTimers()
            StatsManager.shared.endSession()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.96, blue: 0.92),
                Color(red: 0.95, green: 0.93, blue: 0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var noteIndicator: some View {
        switch gameMode {
        case .practice:
            if viewModel.currentNote != nil {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                    Text("Find: Note \(viewModel.currentNoteIndex + 1) of \(roundLength.rawValue)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
        case .timedChallenge:
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("Identify the note!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
        case .streak:
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("Don't break your streak!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var noteInput: some View {
        if notation == .piano {
            PianoKeysView(
                onNoteTapped: { note in
                    viewModel.checkAnswer(note)
                },
                disabled: viewModel.showingFeedback || viewModel.isGameOver
            )
            .padding(.bottom, 40)
        } else {
            NoteButtonsView(
                onNoteTapped: { note in
                    viewModel.checkAnswer(note)
                },
                disabled: viewModel.showingFeedback || viewModel.isGameOver,
                notation: notation
            )
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Game Header View
struct GameHeaderView: View {
    @ObservedObject var viewModel: GameViewModel
    let gameMode: GameMode
    
    var body: some View {
        HStack(spacing: 12) {
            // Mode-specific stats
            switch gameMode {
            case .practice:
                StatBadge(icon: "checkmark.circle.fill", value: "\(viewModel.correctCount)", label: "Correct", color: .green)
                StatBadge(icon: "target", value: String(format: "%.0f%%", viewModel.accuracy), label: "Accuracy", color: .orange)
                
            case .timedChallenge:
                TimerBadge(timeRemaining: viewModel.timeRemaining)
                StatBadge(icon: "checkmark.circle.fill", value: "\(viewModel.correctCount)", label: "Score", color: .green)
                
            case .streak:
                StreakBadge(currentStreak: viewModel.currentStreak, bestStreak: viewModel.bestStreak)
                StatBadge(icon: "checkmark.circle.fill", value: "\(viewModel.correctCount)", label: "Total", color: .green)
            }
            
            ClefBadge(clef: viewModel.currentClef)
            
            // Metronome indicator
            if viewModel.metronomeEnabled {
                MetronomeBadge(isActive: viewModel.metronomeBeat)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

// MARK: - Timer Badge
struct TimerBadge: View {
    let timeRemaining: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .foregroundColor(timeRemaining <= 10 ? .red : .orange)
                    .font(.system(size: 14))
                Text("\(timeRemaining)s")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(timeRemaining <= 10 ? .red : .primary)
            }
            Text("Time")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let currentStreak: Int
    let bestStreak: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                Text("\(currentStreak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text("Streak (Best: \(bestStreak))")
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    let gameMode: GameMode
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Title
                VStack(spacing: 8) {
                    Image(systemName: gameMode == .streak ? "flame.fill" : "flag.checkered")
                        .font(.system(size: 50))
                        .foregroundColor(gameMode == .streak ? .red : .orange)
                    
                    Text(gameMode == .streak ? "Streak Ended!" : "Time's Up!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                // Stats
                VStack(spacing: 16) {
                    if gameMode == .timedChallenge {
                        StatRow(label: "Notes Identified", value: "\(viewModel.correctCount)")
                        StatRow(label: "Total Attempts", value: "\(viewModel.totalAttempts)")
                        StatRow(label: "Accuracy", value: String(format: "%.0f%%", viewModel.accuracy))
                    } else if gameMode == .streak {
                        StatRow(label: "Final Streak", value: "\(viewModel.currentStreak)")
                        StatRow(label: "Best Streak", value: "\(viewModel.bestStreak)")
                        StatRow(label: "Total Correct", value: "\(viewModel.correctCount)")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        onPlayAgain()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        onExit()
                    } label: {
                        Text("Back to Menu")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .padding(32)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Existing Components
struct MetronomeBadge: View {
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "metronome.fill")
                .font(.system(size: 22))
                .foregroundColor(isActive ? .orange : .gray)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isActive)
            Text("Beat")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ClefBadge: View {
    let clef: ClefType
    
    var body: some View {
        VStack(spacing: 4) {
            Text(clef == .bass ? "𝄢" : "𝄞")
                .font(.system(size: 28))
                .foregroundColor(.purple)
            Text(clef == .bass ? "Bass" : "Treble")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        GameView(gameMode: .practice, difficulty: .easy, clefSetting: .treble, notation: .solfege)
    }
}
