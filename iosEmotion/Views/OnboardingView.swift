import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    @State private var step = 1
    
    // Step 1: Name
    @State private var nameInput = ""
    
    // Step 2: Avatar
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedAvatarData: Data?
    
    // Step 3: Bio & Profession
    @State private var professionInput = ""
    @State private var bioInput = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Capsule()
                            .fill(step >= i ? Color("AppPurple") : Color.gray.opacity(0.2))
                            .frame(width: 40, height: 4)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                if step == 1 {
                    VStack(spacing: 20) {
                        Text("What is\nyour name?")
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
                    }
                } else if step == 2 {
                    VStack(spacing: 20) {
                        Text("Add a Profile\nPhoto.")
                            .font(.system(size: 32, weight: .black))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("AppPurple"))
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 150, height: 150)
                                
                                if let data = selectedAvatarData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color("AppPurple"))
                                }
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedAvatarData = data
                                }
                            }
                        }
                        
                        Text("Tap to upload")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if step == 3 {
                    VStack(spacing: 20) {
                        Text("Your Artist\nIdentity.")
                            .font(.system(size: 32, weight: .black))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("AppPurple"))
                        
                        VStack(spacing: 12) {
                            TextField("Profession (e.g. Producer)", text: $professionInput)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            
                            TextField("Brief Bio", text: $bioInput)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Next Button
                Button(action: {
                    if step < 3 {
                        withAnimation { step += 1 }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(step == 3 ? "Create Profile" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceed ? Color("AppPurple") : Color.gray)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
                .disabled(!canProceed)
            }
        }
    }
    
    private var canProceed: Bool {
        if step == 1 { return !nameInput.isEmpty }
        if step == 2 { return true } // Photo is optional
        if step == 3 { return !professionInput.isEmpty }
        return false
    }
    
    private func completeOnboarding() {
        store.currentUser.name = nameInput
        store.currentUser.avatarData = selectedAvatarData
        store.currentUser.profession = professionInput
        store.currentUser.bio = bioInput
        
        withAnimation {
            store.hasCompletedOnboarding = true
            selectedTab = 3 // Jump to Profile tab
        }
    }
}
