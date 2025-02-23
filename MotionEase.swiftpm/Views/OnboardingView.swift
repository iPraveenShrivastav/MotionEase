//
//  File 3.swift
//  MotionEase
//
//  Created by Praveen on 23/02/25.
//

import Foundation
import SwiftUI


struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $currentPage) {
                    
                    // Slide 1: About Motion Sickness
                    onboardingSlide(
                        title: "What is Motion Sickness?",
                        description: "Motion sickness occurs when there is a conflict between the signals your inner ear, eyes, and deeper body parts send to your brain. It can cause symptoms like dizziness, nausea, and discomfort.",
                        icon: "exclamationmark.triangle",
                        backgroundColor: Color.blue.opacity(0.9),
                        tag: 0
                    )
                    
                    // Slide 2: Horizon Gazing
                    onboardingSlide(
                        
                        title: "Horizon Gazing Exercise",
                        description: "Engage in horizon gazing exercises to help stabilize your vision and reduce symptoms of motion sickness.",
                        icon: "eye.circle.fill",
                        backgroundColor: Color.cyan.opacity(0.9),
                        tag: 1
                    )
                    
                    // Slide 3: Breathing Exercises
                    onboardingSlide(
                        
                        title: "Breathing Techniques",
                        description: "Practice guided breathing exercises to promote relaxation and alleviate discomfort during travel.",
                        icon: "lungs.fill",
                        backgroundColor: Color.green.opacity(0.9),
                        tag: 2
                    )
                    
                    // Slide 4: P6 Acupressure
                    onboardingSlide(
                        title: "P6 Acupressure Point",
                        description: "Learn about the P6 acupressure point and how applying pressure can help reduce nausea and motion sickness.",
                        icon: "hand.point.up.left.fill",
                        backgroundColor: Color.orange.opacity(0.9),
                        tag: 3
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isActive = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                    }
                    
                    Spacer()
                    

                    PageIndicator(totalPages: 4, currentPage: currentPage)
                        .padding(.bottom, 20)
                    HStack {
                        Spacer()
                        Button(action: {
                            if currentPage < 3 {
                                currentPage += 1
                            } else {
                                isActive = true
                            }
                        }) {
                            Text(currentPage == 3 ? "Get Started" : "Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitle("Motion Ease", displayMode: .inline)
            .fullScreenCover(isPresented: $isActive) {
                ContentView() 
            }
        }
    }
    
    
    struct PageIndicator: View {
        let totalPages: Int
        let currentPage: Int
        
        var body: some View {
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { page in
                    Circle()
                        .fill(page == currentPage ? Color.cyan : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }


    struct PrimaryButtonStyle: ButtonStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.cyan)
                .foregroundColor(.white)
                .cornerRadius(25)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
    private func onboardingSlide(title: String, description: String, icon: String, backgroundColor: Color, tag: Int) -> some View {
        VStack(spacing: 20) {
            
            Spacer()
            // Icon
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
            
            // Title
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(description)
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.45)
        .padding(.vertical, 20)
        .background(backgroundColor)
        .cornerRadius(25)
        .padding(.horizontal, 20)
        .padding(.top, 0)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .tag(tag)
    }
}

