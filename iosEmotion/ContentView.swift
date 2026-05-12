import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    
    init() {
        // Transparent Tab Bar styling
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.027, green: 0.023, blue: 0.039, alpha: 0.95)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                BehindTheWorkView()
                    .tag(0)
                
                CreateMomentView()
                    .tag(1)
            }
            .environmentObject(store)
            
            // Custom Tab Bar for exact styling
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.05))
                
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
                    
                    Button(action: { selectedTab = 1 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                            Text("Share")
                                .font(.custom("DMMono-Regular", size: 10))
                        }
                        .foregroundColor(.white.opacity(selectedTab == 1 ? 1.0 : 0.22))
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 32)
                .background(Color(hex: "07060a"))
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    ContentView()
}
