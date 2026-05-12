import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    @State private var showingExpress = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.031, green: 0.027, blue: 0.043, alpha: 1.0) // #08070B
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        if !store.hasCompletedOnboarding {
            OnboardingView(selectedTab: $selectedTab)
                .environmentObject(store)
        } else {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    BehindTheWorkView()
                        .tag(0)
                        .environmentObject(store)
                    
                    Color.clear
                        .tag(1)
                }
                
                // Custom Tab Bar
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 1)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: { selectedTab = 0 }) {
                            VStack(spacing: 4) {
                                Image(systemName: selectedTab == 0 ? "circle.inset.filled" : "circle")
                                    .font(.system(size: 20))
                                Text("Feed")
                                    .font(.custom("DMMono-Regular", size: 10))
                            }
                            .foregroundColor(.white.opacity(selectedTab == 0 ? 1.0 : 0.22))
                        }
                        
                        Spacer()
                        Spacer()
                        
                        Button(action: { showingExpress = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                Text("Express")
                                    .font(.custom("DMMono-Regular", size: 10))
                            }
                            .foregroundColor(.white.opacity(0.22))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .background(Color(hex: "08070B"))
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .fullScreenCover(isPresented: $showingExpress) {
                CreateMomentView()
                    .environmentObject(store)
            }
        }
    }
}

#Preview {
    ContentView()
}
