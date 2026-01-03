//
//  StatsView.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overall Stats
                        OverallStatsCard(statsManager: statsManager)
                        
                        // Weekly Progress Chart
                        WeeklyChartCard(statsManager: statsManager)
                        
                        // Weak Notes
                        WeakNotesCard(statsManager: statsManager)
                        
                        // Strong Notes
                        StrongNotesCard(statsManager: statsManager)
                        
                        // All Notes Performance
                        AllNotesCard(statsManager: statsManager)
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            statsManager.resetAllStats()
                        } label: {
                            Label("Reset All Stats", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Overall Stats Card
struct OverallStatsCard: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("All Time Stats")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "music.note.list",
                    value: "\(statsManager.totalNotesAllTime)",
                    label: "Notes Practiced",
                    color: .blue
                )
                
                StatItem(
                    icon: "target",
                    value: String(format: "%.0f%%", statsManager.overallAccuracy),
                    label: "Accuracy",
                    color: .green
                )
                
                StatItem(
                    icon: "clock.fill",
                    value: formatTime(statsManager.totalPracticeTime),
                    label: "Practice Time",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private func formatTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            return "\(seconds / 60)m"
        } else {
            let hours = seconds / 3600
            let mins = (seconds % 3600) / 60
            return "\(hours)h \(mins)m"
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weekly Chart Card
struct WeeklyChartCard: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 Days")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if statsManager.last7DaysStats.contains(where: { $0.totalNotes > 0 }) {
                Chart(statsManager.last7DaysStats) { stat in
                    BarMark(
                        x: .value("Day", formatDayLabel(stat.date)),
                        y: .value("Notes", stat.totalNotes)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .frame(height: 150)
                
                // Accuracy trend
                HStack(spacing: 16) {
                    ForEach(statsManager.last7DaysStats.suffix(3)) { stat in
                        VStack(spacing: 4) {
                            Text(formatDayLabel(stat.date))
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            Text(String(format: "%.0f%%", stat.accuracy))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(accuracyColor(stat.accuracy))
                        }
                    }
                    Spacer()
                }
                .padding(.top, 8)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    Text("No practice data yet")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Start practicing to see your progress!")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private func formatDayLabel(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        return dayFormatter.string(from: date)
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 80 { return .green }
        if accuracy >= 60 { return .yellow }
        return .red
    }
}

// MARK: - Weak Notes Card
struct WeakNotesCard: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Needs Practice")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if statsManager.weakNotes.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Practice more to identify weak notes")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 8)
            } else {
                ForEach(statsManager.weakNotes) { note in
                    NoteProgressRow(
                        noteName: note.noteName,
                        accuracy: note.accuracy,
                        attempts: note.totalAttempts,
                        color: .red
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Strong Notes Card
struct StrongNotesCard: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Your Best Notes")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if statsManager.strongNotes.isEmpty {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.orange)
                    Text("Practice more to see your strengths")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 8)
            } else {
                ForEach(statsManager.strongNotes) { note in
                    NoteProgressRow(
                        noteName: note.noteName,
                        accuracy: note.accuracy,
                        attempts: note.totalAttempts,
                        color: .green
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - All Notes Card
struct AllNotesCard: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Notes Performance")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            let sortedNotes = statsManager.noteStats.sorted { $0.noteName < $1.noteName }
            
            if sortedNotes.isEmpty {
                Text("No data yet. Start practicing!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(sortedNotes) { note in
                        NoteStatCell(note: note)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct NoteStatCell: View {
    let note: NoteStats
    
    private var accuracyColor: Color {
        if note.accuracy >= 80 { return .green }
        if note.accuracy >= 60 { return .yellow }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(note.noteName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(String(format: "%.0f%%", note.accuracy))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(accuracyColor)
            
            Text("\(note.totalAttempts) attempts")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct NoteProgressRow: View {
    let noteName: String
    let accuracy: Double
    let attempts: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(noteName)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(accuracy / 100))
                }
            }
            .frame(height: 8)
            
            Text(String(format: "%.0f%%", accuracy))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(color)
                .frame(width: 45, alignment: .trailing)
        }
    }
}

#Preview {
    StatsView()
}

