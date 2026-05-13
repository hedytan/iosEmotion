import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    @State private var showingCreate = false
    
    init() {
        // Hide standard tab bar to use custom one
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "08070B").ignoresSafeArea()
            
            // MAIN CONTENT SWITCHER
            TabView(selection: $selectedTab) {
                BehindTheWorkView()
                    .environmentObject(store)
                    .tag(0)
                
                // Placeholder for Express tab
                Color.clear
                    .tag(1)
            }
            
            // HIGH-FIDELITY CUSTOM TAB BAR
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.04))
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    // Feed Tab
                    Button(action: { selectedTab = 0 }) {
                        VStack(spacing: 6) {
                            Image(systemName: "circle.circle")
                                .font(.system(size: 22))
                            Text("Feed")
                                .font(.custom("DMMono-Regular", size: 9))
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .opacity(selectedTab == 0 ? 1.0 : 0.22)
                    }
                    
                    // Express Tab
                    Button(action: { showingCreate = true }) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 22))
                            Text("Express")
                                .font(.custom("DMMono-Regular", size: 9))
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .opacity(selectedTab == 1 ? 1.0 : 0.22)
                    }
                }
                .padding(.top, 12)
                .frame(height: 76, alignment: .top)
                .background(
                    Color(hex: "08070B").opacity(0.97)
                        .background(.ultraThinMaterial)
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $showingCreate) {
            CreateMomentView(selectedTab: $selectedTab)
                .environmentObject(store)
        }
    }
}

// Global modifiers for animations
struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 2.2
                    opacity = 0
                }
            }
    }
}

struct FloaterModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = -30
                    opacity = 0
                }
            }
    }
}
