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
        ZStack {
            if !store.hasCompletedOnboarding {
                OnboardingView(selectedTab: $selectedTab)
                    .environmentObject(store)
                    .transition(.opacity)
            } else {
                MainAppView(selectedTab: $selectedTab, showingCreate: $showingCreate)
                    .environmentObject(store)
                    .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showingCreate) {
            CreateMomentView(selectedTab: $selectedTab)
                .environmentObject(store)
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    @Binding var showingCreate: Bool
    
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
            
            // HIGH-FIDELITY GLASS PILL TAB BAR
            HStack(spacing: 0) {
                // Feed Tab
                Button(action: { 
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = 0 
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 20, weight: selectedTab == 0 ? .semibold : .regular))
                        Text("Feed")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .foregroundColor(selectedTab == 0 ? Color(hex: "F0A840") : .white.opacity(0.4))
                    .background(
                        Capsule()
                            .fill(selectedTab == 0 ? Color.black.opacity(0.25) : Color.clear)
                    )
                }
                .padding(4)
                
                // Express Tab
                Button(action: { showingCreate = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .regular))
                        Text("Express")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .foregroundColor(.white.opacity(0.4))
                    .background(Capsule().fill(Color.clear))
                }
                .padding(4)
            }
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.5))
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.bottom, 34)
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
