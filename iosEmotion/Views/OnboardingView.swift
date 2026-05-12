import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Welcome.")
                    .font(.custom("Lora-Italic", size: 32))
                    .italic()
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation {
                        store.hasCompletedOnboarding = true
                        selectedTab = 0
                    }
                }) {
                    Text("Start New Idea")
                        .font(.custom("DMMono-Regular", size: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(4)
                }
            }
        }
    }
}
