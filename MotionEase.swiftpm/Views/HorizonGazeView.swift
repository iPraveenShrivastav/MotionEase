//
//  File 2.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI
import CoreHaptics
@preconcurrency import CoreMotion

@MainActor
struct HorizonGazeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isExerciseActive = false
    @Binding var selectedTab: Int
    @StateObject private var motionManager = MotionManager()
    @State private var focusPoint: CGPoint = .zero
    @State private var smoothedRoll: Double = 0
    @State private var smoothedPitch: Double = 0
    private let smoothingFactor: Double = 0.2
    @State private var isDragging = false
    @State private var showGuide = true
    @State private var exerciseTimer: Timer?
    @State private var exerciseDuration: TimeInterval = 0
    @State private var showExerciseComplete = false
    @State private var deviceOrientation: DeviceOrientation = .flat
    @State private var stabilityScore: Double = 0
    @State private var hapticEngine: CHHapticEngine?
    @State private var calibrationMode = false
    @State private var calibrationProgress: Double = 0
    @State private var calibrationTimer: Timer?
    // Add new properties for enhanced visual feedback
    @State private var dotOpacity: Double = 1.0
    private let focusPointSize: CGFloat = 50  // Larger, stable size for better focus
    
    // Add color properties for visual feedback
    private let focusColors = [
        Color.blue.opacity(0.8),
        Color.cyan.opacity(0.8),
        Color.white.opacity(0.8)
    ]
    @State private var currentColorIndex = 0

    private let recommendedDuration: TimeInterval = 180 // 3 minutes
    private let targetZoneHeight: CGFloat = 120
    private let movementRadius: CGFloat = 200 // Increased for larger movement area
    
    private var centerY: CGFloat {
        UIScreen.main.bounds.height * 0.5 // Center of the screen
    }
    
    private var targetZone: ClosedRange<CGFloat> {
        (centerY - targetZoneHeight/2)...(centerY + targetZoneHeight/2)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.7),
                Color.blue.opacity(0.3),
                Color.white.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    }
    
    private var isInTargetZone: Bool {
        targetZone.contains(focusPoint.y)
    }
    
    @State private var isDeviceStable = false
    @State private var lastMotionUpdate = Date()
    @State private var motionSmoothingQueue: [CGPoint] = []
    private let queueSize = 5 // For motion smoothing
    private let motionThreshold: Double = 0.05
    
    private let motionThresholdForStability: Double = 0.03
    private let stabilityCheckInterval: TimeInterval = 0.5
    private var stabilityTimer: Timer?

    @State private var showCalibrationOverlay = false

    // Add explicit initializer
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Status bar
                    statusBar
                        .padding(.top)
                    
                    // Full movement area
                    ZStack {
                        // Green target zone
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(height: targetZoneHeight)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        
                        // Focus point
                        focusPointView
                            .position(focusPoint)
                    }
                    .frame(height: geometry.size.height * 0.7)
                    
                    Spacer()
                    
                    // Control panel
                    controlPanel
                }
                
                if showCalibrationOverlay {
                    calibrationOverlay
                }
                
                if showGuide {
                    guideOverlay
                }
            }
        }
        .onAppear(perform: setupView)
        .onDisappear(perform: cleanupView)
        .onChange(of: motionManager.roll) { newValue in
            if isExerciseActive {
                updateFocusPoint()
                updateVisualFeedback()
            }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue != 0 {
                stopExercise()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            stopExercise()
        }
    }
    
    private var controlPanel: some View {
        HStack(spacing: 30) {
            Button {
                if !isExerciseActive {
                    startCalibration()
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "scope")
                        .font(.system(size: 20))
                    Text("Calibrate")
                        .font(.system(size: 12))
                }
                .frame(width: 70, height: 70)
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
            }
            .buttonStyle(ControlButtonStyle(isEnabled: !isExerciseActive))
            
            Button {
                if isExerciseActive {
                    stopExercise()
                } else {
                    startExercise()
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: isExerciseActive ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                    Text(isExerciseActive ? "Stop" : "Start")
                        .font(.system(size: 12))
                }
                .frame(width: 70, height: 70)
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
            }
            .buttonStyle(ControlButtonStyle(isEnabled: true))
            
            Button {
                if !isExerciseActive {
                    showGuide = true
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                    Text("Guide")
                        .font(.system(size: 12))
                }
                .frame(width: 70, height: 70)
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
            }
            .buttonStyle(ControlButtonStyle(isEnabled: !isExerciseActive))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
    }
    
    // Add this new button style
    struct ControlButtonStyle: ButtonStyle {
        let isEnabled: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isEnabled ? .white : .gray.opacity(0.5))
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .disabled(!isEnabled)
        }
    }
    
    // Add function to clamp focus point within movement radius
    private func clampedFocusPoint(in geometry: GeometryProxy) -> CGPoint {
        let centerX = geometry.size.width / 2
        let deltaX = focusPoint.x - centerX
        let deltaY = focusPoint.y - centerY
        
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        if distance > movementRadius {
            let scale = movementRadius / distance
            return CGPoint(
                x: centerX + deltaX * scale,
                y: centerY + deltaY * scale
            )
        }
        return focusPoint
    }
    
    // Update focus point view
    private var focusPointView: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.cyan.opacity(0.3))
                .frame(width: focusPointSize + 20, height: focusPointSize + 20)
                .blur(radius: 10)
            
            // Main dot
            Circle()
                .fill(.white)
                .frame(width: focusPointSize, height: focusPointSize)
                .opacity(dotOpacity)
        }
        .scaleEffect(isInTargetZone ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isInTargetZone)
    }
    
    // Update status bar to be more subtle
    private var statusBar: some View {
        HStack {
            // Device orientation
            HStack {
                Image(systemName: deviceOrientation.iconName)
                    .foregroundColor(deviceOrientation.color)
                Text(deviceOrientation.description)
                    .font(.subheadline)
            }
            
            Spacer()
            
            // Timer display
            if isExerciseActive {
                Text(timeString(from: Int(exerciseDuration)))
                    .font(.headline)
                    .monospacedDigit()
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var calibrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Calibrating...")
                    .font(.title)
                    .foregroundColor(.white)
                
                ProgressView(value: calibrationProgress)
                    .frame(width: 200)
                
                Text("Hold your device steady")
                    .foregroundColor(.white)
            }
        }
    }
    
    private var exerciseCompleteModal: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Exercise Complete!")
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration: \(timeString(from: Int(exerciseDuration)))")
                    Text("Average Stability: \(String(format: "%.0f%%", stabilityScore))")
                }
                .foregroundColor(.white)
                
                Button("Close") {
                    withAnimation {
                        showExerciseComplete = false
                    }
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var guideOverlay: some View {
        ZStack {
            // Card content
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Horizon Gazing Exercise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Follow these steps to reduce motion sickness")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(1...4, id: \.self) { index in
                        HStack(alignment: .top, spacing: 16) {
                            // Step number
                            Text("\(index)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.cyan)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                            
                            // Step text
                            Text(getStepText(index))
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Got it button
                Button(action: {
                    withAnimation(.spring()) {
                        showGuide = false
                    }
                }) {
                    Text("Got it")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .white.opacity(0.2), radius: 5)
                }
                .padding(.top, 16)
            }
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .padding(.horizontal, 20)
        }
        .allowsHitTesting(true)
    }
    
    // Helper function to get step text
    private func getStepText(_ step: Int) -> String {
        switch step {
        case 1: return "Hold your device at eye level"
        case 2: return "Focus on the white dot and keep it within the green zone"
        case 3: return "Follow the dot with your eyes, not your head"
        case 4: return "Continue for 3 minutes or until symptoms improve"
        default: return ""
        }
    }
    
    private func startCalibration() {
        withAnimation {
            calibrationMode = true
            calibrationProgress = 0
            showCalibrationOverlay = true
            
            calibrationTimer?.invalidate()
            
            let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    if calibrationProgress < 1.0 {
                        calibrationProgress += 0.1
                        
                        if calibrationProgress >= 1.0 {
                            calibrationMode = false
                            motionManager.calibrate()
                            calibrationTimer?.invalidate()
                            calibrationTimer = nil
                            showCalibrationOverlay = false
                        }
                    }
                }
            }
            calibrationTimer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func startExercise() {
        withAnimation {
            isExerciseActive = true
            exerciseDuration = 0
            exerciseTimer?.invalidate()
            
            // Set the focus point to the center of the green rectangle
            let screenWidth = UIScreen.main.bounds.width
            let greenZoneWidth = screenWidth * 0.8
            let greenZoneCenterX = (screenWidth - greenZoneWidth) / 2 + (greenZoneWidth / 2)
            let greenZoneCenterY = centerY // Center Y position of the green rectangle
            
            // Reset focus point to the center of the green rectangle
            focusPoint = CGPoint(x: greenZoneCenterX, y: greenZoneCenterY)
            
            let timer = Timer(timeInterval: 1, repeats: true) { _ in
                Task { @MainActor in
                    exerciseDuration += 1
                    if exerciseDuration >= recommendedDuration {
                        stopExercise()
                        showExerciseComplete = true
                    }
                }
            }
            exerciseTimer = timer
            RunLoop.main.add(timer, forMode: .common)
            
            motionManager.startMotionUpdates()
        }
    }
    
    private func stopExercise() {
        withAnimation {
            isExerciseActive = false
            exerciseTimer?.invalidate()
            exerciseTimer = nil
            motionManager.stopMotionUpdates()
            
            // Reset focus point to the center of the green rectangle
            let screenWidth = UIScreen.main.bounds.width
            let greenZoneWidth = screenWidth * 0.8
            let greenZoneCenterX = (screenWidth - greenZoneWidth) / 2 + (greenZoneWidth / 2)
            let greenZoneCenterY = centerY // Center Y position of the green rectangle
            
            focusPoint = CGPoint(x: greenZoneCenterX, y: greenZoneCenterY)
        }
    }
    
    private func setupView() {
        setupHaptics()
        // Set focus point to a fixed position
        let screenWidth = UIScreen.main.bounds.width
        let greenZoneWidth = screenWidth * 0.8
        let greenZoneCenterX = (screenWidth - greenZoneWidth) / 2 + (greenZoneWidth / 2)
        let greenZoneCenterY = centerY // Center Y position of the green rectangle
        
        // Set the focus point to the center of the green rectangle
        focusPoint = CGPoint(x: greenZoneCenterX, y: greenZoneCenterY)
    }
    
    private func cleanupView() {
        exerciseTimer?.invalidate()
        exerciseTimer = nil
        calibrationTimer?.invalidate()
        calibrationTimer = nil
        motionManager.stopMotionUpdates()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine creation failed: \(error.localizedDescription)")
        }
    }
    
    private func updateStabilityScore() {
        let distanceFromCenter = abs(focusPoint.y - centerY)
        let maxDistance = targetZoneHeight / 2
        let positionScore = max(0, 100 - (distanceFromCenter / maxDistance * 100))
        
        let motionScore = max(0, 100 - (abs(motionManager.roll) * 100))
        
        withAnimation(.easeInOut) {
            stabilityScore = (positionScore + motionScore) / 2
            isDeviceStable = stabilityScore > 80
        }
    }
    
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func updateFocusPoint() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate green rectangle boundaries
        let greenZoneWidth = screenWidth * 0.8
        let greenZoneLeft = (screenWidth - greenZoneWidth) / 2
        let greenZoneRight = greenZoneLeft + greenZoneWidth
        
        // Define movement boundaries
        let upwardExtension: CGFloat = 40 // Allow slight upward movement
        let minY = centerY - targetZoneHeight - upwardExtension // Allow upward movement
        let maxY = screenHeight * 0.85 // Limit downward movement to just above control panele
        
        // Adjust sensitivities
        let verticalSensitivity: Double = 250
        let horizontalSensitivity: Double = 250
        
        // Calculate movements
        let verticalFactor = CGFloat(motionManager.pitch * verticalSensitivity)
        let horizontalFactor = CGFloat(motionManager.yaw * horizontalSensitivity)
        
        // Calculate new position
        let newX = screenWidth / 2 + horizontalFactor
        let newY = centerY - verticalFactor // Inverted for natural movement
        
        // Clamp the position to movement boundaries
        let clampedX = max(greenZoneLeft, min(greenZoneRight, newX))
        let clampedY = max(minY, min(maxY, newY))
        
        withAnimation(.easeInOut(duration: 0.2)) {
            focusPoint = CGPoint(x: clampedX, y: clampedY)
        }
        
        updateStabilityScore()
        updateDeviceOrientation()
    }
    
    private func updateDeviceOrientation() {
        guard let motion = motionManager.motionManager.deviceMotion else { return }
        
        let z = motion.gravity.z
        
        withAnimation {
            if abs(z) > 0.85 {
                deviceOrientation = .eyeLevel
            } else if abs(z) < 0.45 {
                deviceOrientation = .vertical
            } else {
                deviceOrientation = .flat
            }
        }
    }
    
    private func updateVisualFeedback() {
        // Update dot size based on stability
        withAnimation(.spring()) {
            dotOpacity = isInTargetZone ? 1.0 : 0.7
            currentColorIndex = isInTargetZone ? 2 : (isDeviceStable ? 1 : 0)
        }
        
        // Provide haptic feedback when entering/leaving target zone
        if isInTargetZone {
            
        }
    }
}
