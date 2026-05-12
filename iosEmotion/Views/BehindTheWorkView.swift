import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            VStack {
                Text("New Idea Starts Here.")
                    .font(.custom("Lora-Italic", size: 24))
                    .italic()
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
