//
//  GameViewModel.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var notes: [MusicNote] = []
    @Published var currentNoteIndex: Int = 0
    @Published var lastAnswerResult: AnswerResult = .pending
    @Published var showingFeedback: Bool = false
    @Published var correctCount: Int = 0
    @Published var totalAttempts: Int = 0
    @Published var currentClef: ClefType = .treble
    @Published var metronomeBeat: Bool = false
    
    // Game mode specific
    @Published var timeRemaining: Int = 60
    @Published var isGameOver: Bool = false
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    
    // MARK: - Settings
    var gameMode: GameMode
    var difficulty: Difficulty
    var clefSetting: ClefType
    var roundLength: RoundLength
    var allowedNotes: Set<NoteName>?
    var metronomeEnabled: Bool
    var metronomeSpeed: MetronomeSpeed
    
    // MARK: - Timers
    private var metronomeTimer: Timer?
    private var gameTimer: Timer?
    
    // MARK: - Computed Properties
    var currentNote: MusicNote? {
        guard currentNoteIndex < notes.count else { return nil }
        return notes[currentNoteIndex]
    }
    
    var isRoundComplete: Bool {
        currentNoteIndex >= notes.count
    }
    
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempts) * 100
    }
    
    // MARK: - Initialization
    init(gameMode: GameMode = .practice, difficulty: Difficulty = .easy, clefSetting: ClefType = .treble, roundLength: RoundLength = .short, allowedNotes: Set<NoteName>? = nil, metronomeEnabled: Bool = false, metronomeSpeed: MetronomeSpeed = .moderate) {
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.clefSetting = clefSetting
        self.roundLength = roundLength
        self.allowedNotes = allowedNotes
        self.metronomeEnabled = metronomeEnabled
        self.metronomeSpeed = metronomeSpeed
        self.currentClef = resolveClef()
        
        setupForGameMode()
    }
    
    // MARK: - Game Mode Setup
    private func setupForGameMode() {
        switch gameMode {
        case .practice:
            generateNewRound()
        case .timedChallenge:
            timeRemaining = 60
            generateNewRound()
        case .streak:
            currentStreak = 0
            bestStreak = 0
            generateNewRound()
        }
    }
    
    // MARK: - Game Logic
    func resolveClef() -> ClefType {
        switch clefSetting {
        case .random:
            return Bool.random() ? .treble : .bass
        default:
            return clefSetting
        }
    }
    
    func generateNewRound() {
        currentClef = resolveClef()
        let count = gameMode == .timedChallenge ? 1 : roundLength.rawValue
        notes = NoteGenerator.generateNotes(
            count: count,
            difficulty: difficulty,
            clef: currentClef,
            allowedNotes: allowedNotes
        )
        currentNoteIndex = 0
        lastAnswerResult = .pending
    }
    
    func checkAnswer(_ noteName: NoteName) {
        guard let current = currentNote, !isGameOver else { return }
        
        totalAttempts += 1
        let isCorrect = current.noteName == noteName
        
        // Record stats
        StatsManager.shared.recordAnswer(note: current.noteName, correct: isCorrect)
        
        if isCorrect {
            lastAnswerResult = .correct
            correctCount += 1
            
            switch gameMode {
            case .practice:
                handlePracticeCorrect()
            case .timedChallenge:
                handleTimedChallengeCorrect()
            case .streak:
                handleStreakCorrect()
            }
        } else {
            lastAnswerResult = .incorrect
            
            switch gameMode {
            case .practice, .timedChallenge:
                showFeedback {}
            case .streak:
                handleStreakIncorrect()
            }
        }
    }
    
    // MARK: - Practice Mode
    private func handlePracticeCorrect() {
        showFeedback {
            self.currentNoteIndex += 1
            if self.isRoundComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.generateNewRound()
                }
            }
        }
    }
    
    // MARK: - Timed Challenge Mode
    func startTimer() {
        guard gameMode == .timedChallenge else { return }
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endTimedChallenge()
            }
        }
    }
    
    private func handleTimedChallengeCorrect() {
        showFeedback {
            self.generateNewRound()
        }
    }
    
    private func endTimedChallenge() {
        gameTimer?.invalidate()
        gameTimer = nil
        isGameOver = true
        stopMetronome()
    }
    
    // MARK: - Streak Mode
    private func handleStreakCorrect() {
        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        
        showFeedback {
            self.currentNoteIndex += 1
            if self.isRoundComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.generateNewRound()
                }
            }
        }
    }
    
    private func handleStreakIncorrect() {
        isGameOver = true
        stopMetronome()
        
        showingFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showingFeedback = false
        }
    }
    
    // MARK: - Feedback
    private func showFeedback(completion: @escaping () -> Void) {
        showingFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.showingFeedback = false
            self.lastAnswerResult = .pending
            completion()
        }
    }
    
    // MARK: - Reset
    func resetGame() {
        correctCount = 0
        totalAttempts = 0
        isGameOver = false
        currentStreak = 0
        timeRemaining = 60
        
        setupForGameMode()
        
        if gameMode == .timedChallenge {
            startTimer()
        }
        
        startMetronomeIfNeeded()
    }
    
    func stopAllTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        stopMetronome()
    }
    
    // MARK: - Metronome
    func startMetronomeIfNeeded() {
        guard metronomeEnabled else { return }
        
        stopMetronome()
        
        // Play initial beat
        playMetronomeBeat()
        
        // Start timer for subsequent beats
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: metronomeSpeed.interval, repeats: true) { [weak self] _ in
            self?.playMetronomeBeat()
        }
    }
    
    func stopMetronome() {
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        metronomeBeat = false
    }
    
    private func playMetronomeBeat() {
        AudioManager.shared.playMetronomeTick()
        
        // Visual feedback
        metronomeBeat = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.metronomeBeat = false
        }
    }
}
