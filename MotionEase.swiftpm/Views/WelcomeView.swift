//
//  File 5.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.cyan.opacity(0.5),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image(systemName: "helm")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                    Text("Motion Ease")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Your Journey to Comfort")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
