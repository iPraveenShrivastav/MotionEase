import SwiftUI

@MainActor
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var tabSelection = TabSelectionManager()
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection.selectedTab) {
                NavigationView {
                    HorizonGazeView(selectedTab: $tabSelection.selectedTab)
                        .navigationTitle("Horizon Gazing")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Horizon", systemImage: "eye.circle.fill")
                }
                .tag(0)
                
                NavigationView {
                    BreathingExerciseView()
                        .navigationTitle("Breathing Exercise")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Breathe", systemImage: "lungs.fill")
                }
                .tag(1)
                
                NavigationView {
                    P6GuideView()
                        .navigationTitle("P6 Acupressure")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("P6 Point", systemImage: "hand.point.up.left.fill")
                }
                .tag(2)
            }
            .accentColor(.cyan)
            .environmentObject(tabSelection)
        }
    }
}


