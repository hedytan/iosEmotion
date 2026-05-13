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
                
                // The Express experience is triggered via the custom button, 
                // but we keep a tagged placeholder to manage the warp logic.
                Color.clear
                    .tabItem {
                        Label("Express", systemImage: "plus")
                    }
                    .tag(1)
            }
            .tint(Color(hex: "F0A840"))
            
            // CUSTOM CENTERED 2-PILLAR BUTTONS
            HStack(spacing: 60) {
                // Feed Indicator/Button
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 20))
                        Text("Feed")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == 0 ? Color(hex: "F0A840") : .white.opacity(0.3))
                }
                
                // Express Button
                Button(action: { showingCreate = true }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .light))
                        }
                        Text("Express")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white.opacity(selectedTab == 1 ? 0.6 : 0.3))
                }
            }
            .padding(.bottom, 20)
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingCreate) {
            CreateMomentView(selectedTab: $selectedTab)
                .environmentObject(store)
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
