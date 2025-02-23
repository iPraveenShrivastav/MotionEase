//
//  File 3.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI

enum SymptomSeverity: Int, Codable, CaseIterable, Identifiable {
    case mild = 1
    case moderate = 2
    case severe = 3
    
    var id: Int { rawValue }
    
    var description: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        }
    }
    
    var recommendedDuration: Int {
        switch self {
        case .mild: return 180 // 3 minutes
        case .moderate: return 300 // 5 minutes
        case .severe: return 420 // 7 minutes
        }
    }
    
    var color: Color {
        switch self {
        case .mild: return .blue
        case .moderate: return .orange
        case .severe: return .red
        }
    }
}
