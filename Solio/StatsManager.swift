//
//  StatsManager.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import Foundation
import Combine

// MARK: - Daily Stats
struct DailyStats: Codable, Identifiable {
    var id: String { date }
    let date: String // Format: "yyyy-MM-dd"
    var totalNotes: Int
    var correctNotes: Int
    var practiceTimeSeconds: Int
    
    var accuracy: Double {
        guard totalNotes > 0 else { return 0 }
        return Double(correctNotes) / Double(totalNotes) * 100
    }
}

// MARK: - Note Stats
struct NoteStats: Codable, Identifiable {
    var id: String { noteName }
    let noteName: String
    var totalAttempts: Int
    var correctAttempts: Int
    
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts) * 100
    }
}

// MARK: - Stats Manager
class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    @Published var dailyStats: [DailyStats] = []
    @Published var noteStats: [NoteStats] = []
    
    private let dailyStatsKey = "dailyStats"
    private let noteStatsKey = "noteStats"
    private let dateFormatter: DateFormatter
    
    private var sessionStartTime: Date?
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        loadStats()
    }
    
    // MARK: - Session Management
    func startSession() {
        sessionStartTime = Date()
    }
    
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        let duration = Int(Date().timeIntervalSince(startTime))
        addPracticeTime(seconds: duration)
        sessionStartTime = nil
    }
    
    // MARK: - Recording Stats
    func recordAnswer(note: NoteName, correct: Bool) {
        let today = dateFormatter.string(from: Date())
        
        // Update daily stats
        if let index = dailyStats.firstIndex(where: { $0.date == today }) {
            dailyStats[index].totalNotes += 1
            if correct {
                dailyStats[index].correctNotes += 1
            }
        } else {
            let newStats = DailyStats(
                date: today,
                totalNotes: 1,
                correctNotes: correct ? 1 : 0,
                practiceTimeSeconds: 0
            )
            dailyStats.append(newStats)
        }
        
        // Update note stats
        let noteName = note.rawValue
        if let index = noteStats.firstIndex(where: { $0.noteName == noteName }) {
            noteStats[index].totalAttempts += 1
            if correct {
                noteStats[index].correctAttempts += 1
            }
        } else {
            let newStats = NoteStats(
                noteName: noteName,
                totalAttempts: 1,
                correctAttempts: correct ? 1 : 0
            )
            noteStats.append(newStats)
        }
        
        saveStats()
    }
    
    private func addPracticeTime(seconds: Int) {
        let today = dateFormatter.string(from: Date())
        
        if let index = dailyStats.firstIndex(where: { $0.date == today }) {
            dailyStats[index].practiceTimeSeconds += seconds
        } else {
            let newStats = DailyStats(
                date: today,
                totalNotes: 0,
                correctNotes: 0,
                practiceTimeSeconds: seconds
            )
            dailyStats.append(newStats)
        }
        
        saveStats()
    }
    
    // MARK: - Computed Stats
    var todayStats: DailyStats? {
        let today = dateFormatter.string(from: Date())
        return dailyStats.first(where: { $0.date == today })
    }
    
    var last7DaysStats: [DailyStats] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let dateString = dateFormatter.string(from: date)
            return dailyStats.first(where: { $0.date == dateString }) ?? DailyStats(
                date: dateString,
                totalNotes: 0,
                correctNotes: 0,
                practiceTimeSeconds: 0
            )
        }.reversed()
    }
    
    var totalNotesAllTime: Int {
        dailyStats.reduce(0) { $0 + $1.totalNotes }
    }
    
    var totalCorrectAllTime: Int {
        dailyStats.reduce(0) { $0 + $1.correctNotes }
    }
    
    var overallAccuracy: Double {
        guard totalNotesAllTime > 0 else { return 0 }
        return Double(totalCorrectAllTime) / Double(totalNotesAllTime) * 100
    }
    
    var totalPracticeTime: Int {
        dailyStats.reduce(0) { $0 + $1.practiceTimeSeconds }
    }
    
    var weakNotes: [NoteStats] {
        noteStats
            .filter { $0.totalAttempts >= 5 } // Only consider notes with enough attempts
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(3)
            .map { $0 }
    }
    
    var strongNotes: [NoteStats] {
        noteStats
            .filter { $0.totalAttempts >= 5 }
            .sorted { $0.accuracy > $1.accuracy }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - Persistence
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(dailyStats) {
            UserDefaults.standard.set(encoded, forKey: dailyStatsKey)
        }
        if let encoded = try? JSONEncoder().encode(noteStats) {
            UserDefaults.standard.set(encoded, forKey: noteStatsKey)
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: dailyStatsKey),
           let decoded = try? JSONDecoder().decode([DailyStats].self, from: data) {
            dailyStats = decoded
        }
        if let data = UserDefaults.standard.data(forKey: noteStatsKey),
           let decoded = try? JSONDecoder().decode([NoteStats].self, from: data) {
            noteStats = decoded
        }
    }
    
    func resetAllStats() {
        dailyStats = []
        noteStats = []
        saveStats()
    }
}

