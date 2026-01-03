//
//  HomeView.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedGameMode: GameMode = .practice
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var selectedClef: ClefType = .treble
    @State private var selectedNotation: NoteNotation = .solfege
    @State private var selectedRoundLength: RoundLength = .short
    @State private var selectedNotes: Set<NoteName> = Set(NoteName.allCases)
    @State private var metronomeEnabled: Bool = false
    @State private var selectedMetronomeSpeed: MetronomeSpeed = .moderate
    @State private var isMuted: Bool = false
    @State private var hapticEnabled: Bool = true
    @State private var navigateToGame = false
    @State private var showStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.3),
                        Color(red: 0.1, green: 0.1, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Musical notes decoration (static positions for performance)
                GeometryReader { geo in
                    let positions: [(x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double)] = [
                        (0.15, 0.12, 45, -15), (0.85, 0.08, 35, 20),
                        (0.1, 0.35, 50, 10), (0.9, 0.4, 40, -25),
                        (0.2, 0.65, 38, 15), (0.8, 0.7, 55, -10),
                        (0.12, 0.88, 42, 25), (0.88, 0.92, 48, -20)
                    ]
                    ForEach(0..<8, id: \.self) { i in
                        Text(["♪", "♫", "♩", "♬"][i % 4])
                            .font(.system(size: positions[i].size))
                            .foregroundColor(.white.opacity(0.1))
                            .position(
                                x: geo.size.width * positions[i].x,
                                y: geo.size.height * positions[i].y
                            )
                            .rotationEffect(.degrees(positions[i].rotation))
                    }
                }
                
                VStack(spacing: 0) {
                    // Settings cards in ScrollView
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header with stats button
                            HStack {
                                Spacer()
                                Button {
                                    showStats = true
                                } label: {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.orange)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                        )
                                }
                            }
                            .padding(.top, 8)
                            
                            // Title
                            VStack(spacing: 6) {
                                Text("🎼")
                                    .font(.system(size: 50))
                                
                                Text("Solio")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .pink, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Master Music Notes")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.bottom, 8)
                            // Game Mode selector
                            SettingsCard(title: "Game Mode") {
                                VStack(alignment: .leading, spacing: 10) {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                        ForEach(GameMode.allCases, id: \.self) { mode in
                                            GameModeButton(
                                                mode: mode,
                                                isSelected: selectedGameMode == mode,
                                                onTap: { selectedGameMode = mode }
                                            )
                                        }
                                    }
                                    
                                    Text(selectedGameMode.description)
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            // Difficulty selector
                            SettingsCard(title: "Difficulty") {
                                VStack(alignment: .leading, spacing: 10) {
                                    Picker("Difficulty", selection: $selectedDifficulty) {
                                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                            Text(difficulty.displayName).tag(difficulty)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    
                                    Text(selectedDifficulty.description)
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            // Clef selector
                            SettingsCard(title: "Clef") {
                                Picker("Clef", selection: $selectedClef) {
                                    ForEach(ClefType.allCases, id: \.self) { clef in
                                        Text(clef.displayName).tag(clef)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Input style selector
                            SettingsCard(title: "Input Style") {
                                Picker("Input", selection: $selectedNotation) {
                                    ForEach(NoteNotation.allCases, id: \.self) { notation in
                                        Text(notation.displayName).tag(notation)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Round length selector (only for practice mode)
                            if selectedGameMode == .practice {
                                SettingsCard(title: "Round Length") {
                                    Picker("Round Length", selection: $selectedRoundLength) {
                                        ForEach(RoundLength.allCases, id: \.self) { length in
                                            Text(length.displayName).tag(length)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            
                            // Custom note range selector
                            SettingsCard(title: "Practice Notes") {
                                VStack(alignment: .leading, spacing: 10) {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                        ForEach(NoteName.allCases, id: \.self) { note in
                                            NoteToggleButton(
                                                note: note,
                                                isSelected: selectedNotes.contains(note),
                                                onToggle: {
                                                    if selectedNotes.contains(note) {
                                                        // Don't allow deselecting if it's the last one
                                                        if selectedNotes.count > 1 {
                                                            selectedNotes.remove(note)
                                                        }
                                                    } else {
                                                        selectedNotes.insert(note)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    
                                    // Quick select buttons
                                    HStack(spacing: 8) {
                                        Button("All") {
                                            selectedNotes = Set(NoteName.allCases)
                                        }
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.orange)
                                        
                                        Button("C-E-G") {
                                            selectedNotes = [.Do, .Mi, .Sol]
                                        }
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.orange)
                                        
                                        Button("C-D-E") {
                                            selectedNotes = [.Do, .Re, .Mi]
                                        }
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.orange)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            
                            // Metronome settings
                            SettingsCard(title: "Metronome") {
                                VStack(alignment: .leading, spacing: 12) {
                                    Toggle(isOn: $metronomeEnabled) {
                                        HStack {
                                            Image(systemName: "metronome.fill")
                                                .foregroundColor(metronomeEnabled ? .orange : .gray)
                                            Text(metronomeEnabled ? "Metronome On" : "Metronome Off")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .tint(.orange)
                                    
                                    if metronomeEnabled {
                                        Picker("Speed", selection: $selectedMetronomeSpeed) {
                                            ForEach(MetronomeSpeed.allCases, id: \.self) { speed in
                                                Text(speed.displayName).tag(speed)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                            }
                            
                            // Sound & Haptic toggles
                            SettingsCard(title: "Feedback") {
                                VStack(spacing: 12) {
                                    Toggle(isOn: Binding(
                                        get: { !isMuted },
                                        set: { 
                                            isMuted = !$0
                                            AudioManager.shared.isMuted = isMuted
                                        }
                                    )) {
                                        HStack {
                                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                                .foregroundColor(isMuted ? .gray : .orange)
                                            Text(isMuted ? "Sound Off" : "Sound On")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .tint(.orange)
                                    
                                    Toggle(isOn: $hapticEnabled) {
                                        HStack {
                                            Image(systemName: hapticEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                                .foregroundColor(hapticEnabled ? .orange : .gray)
                                            Text(hapticEnabled ? "Vibration On" : "Vibration Off")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    // Start button
                    Button {
                        navigateToGame = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selectedGameMode.icon)
                                .font(.system(size: 20))
                            Text(selectedGameMode == .practice ? "Start Practice" : "Start \(selectedGameMode.displayName)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(
                    gameMode: selectedGameMode,
                    difficulty: selectedDifficulty,
                    clefSetting: selectedClef,
                    notation: selectedNotation,
                    roundLength: selectedRoundLength,
                    allowedNotes: selectedNotes.count == NoteName.allCases.count ? nil : selectedNotes,
                    metronomeEnabled: metronomeEnabled,
                    metronomeSpeed: selectedMetronomeSpeed,
                    hapticEnabled: hapticEnabled
                )
            }
            .fullScreenCover(isPresented: $showStats) {
                StatsView()
            }
        }
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct NoteToggleButton: View {
    let note: NoteName
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(note.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.orange : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.orange : Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let onTap: () -> Void
    
    private var modeColor: Color {
        switch mode {
        case .practice: return .blue
        case .timedChallenge: return .orange
        case .streak: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16))
                Text(mode.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? modeColor : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? modeColor : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}

