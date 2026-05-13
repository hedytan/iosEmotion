import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    @State private var showingCreate = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "08070B").ignoresSafeArea()
            
            // VIEW SWITCHER
            Group {
                if selectedTab == 0 {
                    BehindTheWorkView()
                        .environmentObject(store)
                        .transition(.opacity)
                } else {
                    BehindTheWorkView()
                        .environmentObject(store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
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
