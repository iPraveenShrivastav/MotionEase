//
//  File.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import CoreGraphics

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    func divided(by value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x / value, y: self.y / value)
    }
}
