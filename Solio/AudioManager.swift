//
//  AudioManager.swift
//  Solio
//
//  Created by noamk on 02/01/2026.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayers: [NoteName: AVAudioPlayer] = [:]
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    var isMuted: Bool = false
    private var isReady: Bool = false
    
    private init() {
        // Load sounds in background to not block app startup
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.preloadSounds()
            self?.setupMetronome()
            DispatchQueue.main.async {
                self?.isReady = true
            }
        }
    }
    
    private func preloadSounds() {
        for note in NoteName.allCases {
            let fileName = note.rawValue.lowercased() // "do", "re", "mi", etc.
            
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    DispatchQueue.main.async { [weak self] in
                        self?.audioPlayers[note] = player
                    }
                } catch {
                    print("Failed to load sound for \(note.rawValue): \(error)")
                }
            } else {
                print("Sound file not found: \(fileName).wav")
            }
        }
    }
    
    private func setupMetronome() {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
            DispatchQueue.main.async { [weak self] in
                self?.audioEngine = engine
                self?.playerNode = player
            }
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    func playNote(_ note: NoteName) {
        guard !isMuted, let player = audioPlayers[note] else { return }
        
        // Reset to beginning if already playing
        player.currentTime = 0
        player.play()
    }
    
    func playMetronomeTick() {
        guard !isMuted,
              let engine = audioEngine,
              let player = playerNode else { return }
        
        // Generate a short click sound
        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let channelCount = Int(engine.mainMixerNode.outputFormat(forBus: 0).channelCount)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        
        let duration: Double = 0.05
        let numSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples)) else { return }
        buffer.frameLength = AVAudioFrameCount(numSamples)
        
        guard let floatChannelData = buffer.floatChannelData else { return }
        
        // Generate a click sound (short sine wave with fast decay)
        let frequency: Double = 1000.0 // High pitch click
        for i in 0..<numSamples {
            let time = Double(i) / sampleRate
            let envelope = Float(1.0 - (time / duration)) // Fast linear decay
            let wave = Float(sin(2.0 * .pi * frequency * time))
            let sample = wave * envelope * envelope * 0.5
            
            for channel in 0..<channelCount {
                floatChannelData[channel][i] = sample
            }
        }
        
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }
}
