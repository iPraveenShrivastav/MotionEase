//
//  File 2.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1/60
    
    @Published private(set) var roll: Double = 0
    @Published private(set) var pitch: Double = 0
    @Published private(set) var yaw: Double = 0
    private var baseRoll: Double = 0
    private var basePitch: Double = 0
    
    init() {
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    func startMotionUpdates() {
        guard !motionManager.isDeviceMotionActive else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self,
                  let motion = motion else { return }
            
            self.yaw = motion.attitude.yaw
            self.pitch = motion.attitude.pitch
           
            let x = motion.gravity.x
            let y = motion.gravity.y
            let z = motion.gravity.z
           
            if abs(z) < 0.45 {
                self.roll = motion.attitude.yaw
            } else { 
                self.roll = atan2(y, z)
            }
        }
    }
    
    func calibrate() {
        if let motion = motionManager.deviceMotion {
            baseRoll = motion.attitude.yaw
            basePitch = motion.attitude.pitch
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
