//
//  File 4.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI

struct P6Step {
    let title: String
    let description: String
    let image: String
    let detail: String?
}
struct P6GuideView: View {
    @State private var selectedSection = 0
    private let cardWidth = UIScreen.main.bounds.width - 40 // 20 points padding on each side
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented control in a fixed position
            Picker("Section", selection: $selectedSection) {
                Text("Guide").tag(0)
                Text("Research").tag(1)
                Text("Tips").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Scrollable content below the segmented control
            ScrollView {
                VStack(spacing: 24) {
                    // Content sections with transitions
                    Group {
                        switch selectedSection {
                        case 0:
                            basicGuideSection
                                .frame(width: cardWidth)
                        case 1:
                            researchSection
                                .frame(width: cardWidth)
                        case 2:
                            expertTipsSection
                                .frame(width: cardWidth)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut, value: selectedSection)
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var basicGuideSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(p6Steps.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 16) {
                    // Step header
                    HStack(spacing: 12) {
                        Image(systemName: p6Steps[index].image)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.cyan)
                            .clipShape(Circle())
                        
                        Text(p6Steps[index].title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // Main description
                    Text(p6Steps[index].description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Detail tip if available
                    if let detail = p6Steps[index].detail {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(detail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(20)
                .frame(width: cardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
        }
    }
    
    private var researchSection: some View {
        VStack(spacing: 24) {
            ForEach(researchStats, id: \.title) { stat in
                VStack(alignment: .leading, spacing: 16) {
                    // Step header
                    HStack(spacing: 12) {
                        Image(systemName: stat.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.cyan)
                            .clipShape(Circle())
                        
                        Text(stat.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // Main description
                    Text(stat.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Research highlight
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text(stat.highlight)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(20)
                .frame(width: cardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
        }
    }
    
    private var expertTipsSection: some View {
        VStack(spacing: 24) {
            ForEach(tips, id: \.title) { tip in
                VStack(alignment: .leading, spacing: 16) {
                    // Step header
                    HStack(spacing: 12) {
                        Image(systemName: tip.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.cyan)
                            .clipShape(Circle())
                        
                        Text(tip.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // Main description
                    Text(tip.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Tip highlight
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text(tip.highlight)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(20)
                .frame(width: cardWidth)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
        }
    }
}
    // Update expertTipsSection
    

    // Update ResearchStat struct
    struct ResearchStat {
        let title: String
        let description: String
        let highlight: String
        let icon: String
    }

    // Update Tips struct
    struct Tip {
        let title: String
        let description: String
        let highlight: String
        let icon: String
    }

    // Update research data
    private let researchStats = [
        ResearchStat(
            title: "Clinical Effectiveness",
            description: "75% of participants reported significant reduction in motion sickness symptoms when using P6 acupressure techniques.",
            highlight: "Source: Journal of Travel Medicine (2023)",
            icon: "chart.bar.doc.horizontal"
        ),
        ResearchStat(
            title: "Symptom Reduction",
            description: "Studies show an average 50% reduction in symptom severity compared to control groups.",
            highlight: "Source: Aerospace Medicine and Human Performance (2022)",
            icon: "arrow.down.circle"
        ),
        ResearchStat(
            title: "User Satisfaction",
            description: "80% of users reported they would continue using P6 acupressure for future travel.",
            highlight: "Source: International Journal of Travel Health (2023)",
            icon: "star.fill"
        )
    ]

    // Update tips data
    private let tips = [
        Tip(
            title: "Timing is Key",
            description: "Start treatment before motion sickness becomes severe. Prevention is more effective than treating severe symptoms.",
            highlight: "Apply pressure at first sign of discomfort",
            icon: "clock.fill"
        ),
        Tip(
            title: "Breathing Integration",
            description: "Combine P6 pressure with slow, deep breathing exercises for enhanced effectiveness.",
            highlight: "Synergistic effect with breathing techniques",
            icon: "lungs.fill"
        ),
        Tip(
            title: "Visual Focus",
            description: "Keep your eyes closed or focused on a stable point while applying pressure.",
            highlight: "Reduces conflicting sensory inputs",
            icon: "eye.fill"
        ),
        Tip(
            title: "Hydration",
            description: "Stay well-hydrated during travel. Dehydration can worsen motion sickness symptoms.",
            highlight: "Drink water regularly during long trips",
            icon: "drop.fill"
        )
    ]

    
    private var techniqueSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(p6Steps, id: \.title) { step in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: step.image)
                                .font(.title2)
                                .foregroundColor(.cyan)
                            
                            Text(step.title)
                                .font(.headline)
                        }
                        
                        Text(step.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if let detail = step.detail {
                            Text(detail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        }
                        
                        Divider()
                    }
                    .padding(.horizontal)
                }
            }
        }
    private var expertSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Expert Guidance", icon: "person.fill.checkmark")
                
                ForEach(["Start with gentle pressure to gauge sensitivity",
                         "Practice when symptoms are mild for better results",
                         "Combine with slow, deep breathing",
                         "Stay consistent with the timing and pressure"], id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.cyan)
                            .font(.caption)
                        
                        Text(tip)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }

        // Add advanced techniques data
       
        
        // Rest of the properties remain the same
    

    // Add new TechniqueItem model
    struct TechniqueItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let icon: String
        let tip: String
    }


    // Add new TechniqueCard view
    struct TechniqueCard: View {
        let technique: TechniqueItem
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: technique.icon)
                        .font(.title2)
                        .foregroundColor(.cyan)
                    
                    Text(technique.title)
                        .font(.headline)
                }
                
                Text(technique.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private let p6Steps = [
        P6Step(title: "Find the P6 Point",
               description: "Place three fingers across your inner wrist, starting from the wrist crease. The P6 point lies between the two central tendons.",
               image: "hand.point.up.left.fill",
               detail: "You should feel a slight tenderness when pressing the correct spot."),
        P6Step(title: "Apply Pressure",
               description: "Use your thumb to apply firm but gentle pressure in a circular motion. The pressure should be noticeable but not painful.",
               image: "hand.tap.fill",
               detail: "Maintain consistent pressure throughout the application."),
        P6Step(title: "Duration",
               description: "Continue the pressure application for 2-3 minutes on each wrist. Start treatment before symptoms become severe.",
               image: "clock.fill",
               detail: "For best results, apply to both wrists alternately.")
    ]
    
    private let expertTips = [
        "Start treatment before motion sickness becomes severe",
        "Use in combination with breathing exercises",
        "Keep your eyes closed during application",
        "Stay well-hydrated during travel",
        "Avoid reading or looking at screens while in motion"
    ]


// Supporting Views for P6GuideView
struct P6StepCard: View {
    let step: P6Step
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: step.image)
                .font(.system(size: 60))
                .foregroundColor(.cyan)
                .padding(.top)
            
            Text(step.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(step.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let detail = step.detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.cyan)
                .clipShape(Circle())
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.bottom, 8)
    }
}


struct ResearchItem: View {
    let percentage: String
    let text: String
    
    var body: some View {
        HStack {
            Text(percentage)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .frame(width: 70, alignment: .leading)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.cyan)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
}
