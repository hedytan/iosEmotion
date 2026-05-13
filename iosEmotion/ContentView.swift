import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    @State private var showingCreate = false
    
    init() {
        // Customize Tab Bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "08070B")
        appearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                BehindTheWorkView()
                    .environmentObject(store)
                    .tabItem {
                        Label("Feed", systemImage: "circle.circle")
                    }
                    .tag(0)
                
                ExploreView()
                    .environmentObject(store)
                    .tabItem {
                        Label("Explore", systemImage: "sparkles")
                    }
                    .tag(1)
                
                // Placeholder for the center action
                Color.clear
                    .tabItem {
                        Label("Express", systemImage: "plus")
                    }
                    .tag(2)
            }
            .tint(Color(hex: "F0A840"))
            
            // Custom Center Button Overlay
            Button(action: { showingCreate = true }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .offset(y: -12) // Position above tab bar
        }
        .fullScreenCover(isPresented: $showingCreate) {
            CreateMomentView(selectedTab: $selectedTab)
                .environmentObject(store)
        }
    }
}

#Preview {
    ContentView()
}
