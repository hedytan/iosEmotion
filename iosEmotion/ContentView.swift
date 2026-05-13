import SwiftUI

struct ContentView: View {
    @StateObject var store = PostStore()
    @State private var selectedTab = 0
    @State private var showingCreate = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "08070B").ignoresSafeArea()
            
            // VIEW SWITCHER (Replaces Native TabView)
            Group {
                if selectedTab == 0 {
                    BehindTheWorkView()
                        .environmentObject(store)
                        .transition(.opacity)
                } else {
                    // We stay on Feed but show Express as a cover
                    BehindTheWorkView()
                        .environmentObject(store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // CUSTOM PILL TAB BAR
            HStack(spacing: 0) {
                // Feed Tab
                Button(action: { 
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = 0 
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 20, weight: selectedTab == 0 ? .medium : .light))
                        Text("Feed")
                            .font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == 0 ? Color(hex: "F0A840") : .white.opacity(0.3))
                }
                .background(
                    Capsule()
                        .fill(Color.white.opacity(selectedTab == 0 ? 0.08 : 0))
                        .padding(4)
                )
                
                // Express Tab (Button)
                Button(action: { showingCreate = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .light))
                        Text("Express")
                            .font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white.opacity(0.3))
                }
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0))
                        .padding(4)
                )
            }
            .frame(width: 240)
            .padding(8)
            .background(
                Capsule()
                    .fill(Color(hex: "1A191D").opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
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
