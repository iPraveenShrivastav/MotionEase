//
//  File.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI

struct BreathingExerciseView: View {
    @State private var showingSeverityPicker = true
    @State private var selectedSeverity: SymptomSeverity = .moderate
    @StateObject private var exerciseManager: BreathingExerciseManager
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var tabSelection: TabSelectionManager

    init() {
        let initialSeverity = SymptomSeverity.moderate
        _exerciseManager = StateObject(wrappedValue: BreathingExerciseManager(severity: initialSeverity))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if showingSeverityPicker {
                severitySelectionView
            } else {
                
                exerciseView
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                exerciseManager.pauseExercise()
            }
        }
        .onChange(of: tabSelection.selectedTab) { newTab in
                    if newTab != 1 && exerciseManager.isActive {
                        exerciseManager.isPaused = true
                        exerciseManager.timer?.invalidate()
                        exerciseManager.timer = nil
                    }
                }
        .alert("Exercise Complete", isPresented: $exerciseManager.showCompletion) {
            Button("Done", role: .cancel) {
                showingSeverityPicker = true
            }
        } message: {
            Text("Great job! You've completed your breathing session. Remember to take regular breaks during travel to maintain comfort.")
        }
    }
    
    private var severitySelectionView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Motion Sickness Intensity")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select your current symptom level")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                ForEach(SymptomSeverity.allCases) { severity in
                    SeverityOptionButton(
                        severity: severity,
                        isSelected: selectedSeverity == severity,
                        action: { selectedSeverity = severity }
                    )
                }
            }
            .padding(.vertical)
            
            VStack(spacing: 8) {
                Text("Recommended Session:")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "clock.fill")
                    Text("\(selectedSeverity.recommendedDuration / 60) minutes")
                }
                .foregroundColor(.secondary)
            }
            
            Button(action: startExercise) {
                Text("Begin Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedSeverity.color)
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private var exerciseView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Breathing Exercise")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                let maxCycles = selectedSeverity == .mild ? 7 :
                               selectedSeverity == .moderate ? 12 : 17
                
                Text("Cycle \(exerciseManager.cycleCount + 1) of \(maxCycles)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Main Circle
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 20)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: 1 - (exerciseManager.timeRemaining / exerciseManager.currentPhase.duration))
                    .stroke(selectedSeverity.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.2), value: exerciseManager.timeRemaining)
                
                VStack(spacing: 16) {
                    Image(systemName: exerciseManager.currentPhase.systemImage)
                        .font(.system(size: 44))
                        .foregroundColor(selectedSeverity.color)
                    
                    Text(exerciseManager.currentPhase.instruction)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(String(format: "%.1f", exerciseManager.timeRemaining))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            
            Spacer()
            
            // Progress Bar
            ProgressView(
                       value: Double(exerciseManager.cycleCount),
                       total: Double(selectedSeverity == .mild ? 7 : selectedSeverity == .moderate ? 12 : 17)
                   )
                   .progressViewStyle(LinearProgressViewStyle(tint: selectedSeverity.color))
                   .padding(.horizontal)
                   

            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    if exerciseManager.isPaused {
                        exerciseManager.resumeExercise()
                    } else {
                        exerciseManager.pauseExercise()
                    }
                }) {
                    Text(exerciseManager.isPaused ? "Resume" : "Pause")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(exerciseManager.isPaused ? Color.green : Color.orange)
                        .cornerRadius(25)
                }
                
                Button(action: {
                    exerciseManager.stopExercise()
                    showingSeverityPicker = true
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func startExercise() {
        showingSeverityPicker = false
        exerciseManager.selectedSeverity = selectedSeverity
        exerciseManager.startExercise()
    }
}

// MARK: - Supporting Views
struct SeverityOptionButton: View {
    let severity: SymptomSeverity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(severity.description)
                        .font(.headline)
                    
                    Text(severityDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(severity.color)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? severity.color : Color.secondary.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var severityDescription: String {
        switch severity {
        case .mild:
            return NSLocalizedString("Slight discomfort, can function normally", comment: "")
        case .moderate:
            return NSLocalizedString("Noticeable symptoms, affecting activities", comment: "")
        case .severe:
            return NSLocalizedString("Strong symptoms, difficult to function", comment: "")
        }
    }
}

