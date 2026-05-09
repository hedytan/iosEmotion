import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    
    // Name Input
    @State private var nameInput = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("What is your\nArtist Name?")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("AppPurple"))
                    
                    TextField("Enter name...", text: $nameInput)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                    
                    Text("This name will be linked to all your creations.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Finish Button
                Button(action: {
                    completeOnboarding()
                }) {
                    Text("Create Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!nameInput.isEmpty ? Color("AppPurple") : Color.gray)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
                .disabled(nameInput.isEmpty)
            }
        }
    }
    
    private func completeOnboarding() {
        store.currentUser.name = nameInput
        // Set default values for other profile fields
        store.currentUser.profession = "Artist"
        store.currentUser.bio = "Creating in Resonance."
        
        withAnimation {
            store.hasCompletedOnboarding = true
            selectedTab = 3 // Jump to Profile tab
        }
    }
}
