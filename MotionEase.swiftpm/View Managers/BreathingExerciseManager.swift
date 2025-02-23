//
//  File.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import CoreHaptics

// MARK: - Exercise States
enum ExercisePhase: Equatable {
    case ready
    case inhale
    case holdBreath
    case exhale
    case rest
    
    var duration: Double {
        switch self {
        case .ready: return 3
        case .inhale: return 4
        case .holdBreath: return 7
        case .exhale: return 8
        case .rest: return 2
        }
    }
    
    var instruction: String {
        switch self {
        case .ready: return NSLocalizedString("Get ready...", comment: "")
        case .inhale: return NSLocalizedString("Inhale slowly through nose", comment: "")
        case .holdBreath: return NSLocalizedString("Hold your breath", comment: "")
        case .exhale: return NSLocalizedString("Exhale completely", comment: "")
        case .rest: return NSLocalizedString("Reset and prepare", comment: "")
        }
    }
    
    var systemImage: String {
        switch self {
        case .ready: return "arrow.up.circle"
        case .inhale: return "arrow.up.circle.fill"
        case .holdBreath: return "circle.fill"
        case .exhale: return "arrow.down.circle.fill"
        case .rest: return "circle"
        }
    }
}

class BreathingExerciseManager: ObservableObject {
    @Published var currentPhase: ExercisePhase = .ready
    @Published var timeRemaining: Double = 3
    @Published var cycleCount: Int = 0
    @Published var isActive = false
    @Published var isPaused = false
    @Published var showCompletion = false
    @Published var sessions: [ExerciseSession] = []
    @Published var selectedSeverity: SymptomSeverity
    
    internal var timer: Timer?
    private var hapticEngine: CHHapticEngine?
    
    init(severity: SymptomSeverity) {
        self.selectedSeverity = severity
        setupHaptics()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptics error: \(error)")
        }
    }
    
    
    func startExercise() {
        isActive = true
        isPaused = false
        cycleCount = 0
        currentPhase = .ready
        timeRemaining = currentPhase.duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateExercise()
        }
    }
    
    func pauseExercise() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resumeExercise() {
        isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateExercise()
        }
    }
    
    func stopExercise() {
        isActive = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        
        if cycleCount > 0 {
            let session = ExerciseSession(
                date: Date(),
                duration: Int(selectedSeverity.recommendedDuration),
                severity: selectedSeverity,
                completedCycles: cycleCount
            )
            sessions.append(session)
            showCompletion = true
        }
    }
    
    private func updateExercise() {
        guard !isPaused else { return }
        
        timeRemaining -= 0.1
        
        if timeRemaining <= 0 {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        switch currentPhase {
        case .ready:
            currentPhase = .inhale
        case .inhale:
            currentPhase = .holdBreath
        case .holdBreath:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .rest
        case .rest:
            cycleCount += 1
            if cycleCount >= getMaxCycles() {
                stopExercise()
                return
            }
            currentPhase = .inhale
        }
        
        timeRemaining = currentPhase.duration
        triggerHapticFeedback()
    }
    
    private func getMaxCycles() -> Int {
        switch selectedSeverity {
        case .mild: return 7
        case .moderate: return 12
        case .severe: return 17
        }
    }
    
    private func triggerHapticFeedback() {
        guard let engine = hapticEngine else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
}
