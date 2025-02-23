//
//  File.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI

enum DeviceOrientation {
    case flat, tilted, vertical, eyeLevel
    
    var iconName: String {
        switch self {
        case .flat: return "iphone.landscape"
        case .tilted: return "iphone.landscape.slash"
        case .vertical: return "iphone"
        case .eyeLevel: return "checkmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .flat: return "Rotate"
        case .tilted: return "Adjust"
        case .vertical: return "Optimal"
        case .eyeLevel: return "Optimal"
        }
    }
    
    var color: Color {
        switch self {
        case .flat: return .red
        case .tilted: return .orange
        case .vertical: return .green
        case .eyeLevel: return .green
        }
    }
}
