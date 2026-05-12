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
            Color(hex: "07060a").ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Top Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Circle()
                            .fill(step >= i ? Color(hex: "f0a840") : Color.white.opacity(0.1))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("STEP \(step)")
                        .font(.custom("DMMono-Regular", size: 10))
                        .foregroundColor(Color(hex: "f0a840"))
                        .kerning(2)
                    
                    Text(stepTitle)
                        .font(.custom("Lora-Italic", size: 32))
                        .italic()
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                
                // Content Area
                VStack(spacing: 30) {
                    if step == 1 {
                        TextField("Your name...", text: $nameInput)
                            .font(.custom("Lora-Italic", size: 24))
                            .italic()
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                            .overlay(Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1), alignment: .bottom)
                    } else if step == 2 {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let data = selectedAvatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .frame(width: 120, height: 120)
                                    .overlay(Image(systemName: "camera").foregroundColor(.white.opacity(0.3)))
                            }
                        }
                    } else {
                        VStack(spacing: 24) {
                            TextField("Profession (e.g. Dreamer)", text: $professionInput)
                                .font(.custom("DMMono-Regular", size: 14))
                                .foregroundColor(.white)
                            
                            TextField("A short bio...", text: $bioInput)
                                .font(.custom("Lora-Italic", size: 16))
                                .italic()
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if step > 1 {
                        Button(action: { withAnimation { step -= 1 } }) {
                            Text("back")
                                .font(.custom("DMMono-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if step < 3 {
                            withAnimation { step += 1 }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(step == 3 ? "complete" : "next")
                            .font(.custom("DMMono-Regular", size: 12))
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(canProceed ? Color.white : Color.white.opacity(0.1))
                            .cornerRadius(4)
                    }
                    .disabled(!canProceed)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedAvatarData = data
                }
            }
        }
    }
    
    private var stepTitle: String {
        switch step {
        case 1: return "What should we call you?"
        case 2: return "An image of your soul."
        case 3: return "How do you express?"
        default: return ""
        }
    }
    
    private var canProceed: Bool {
        if step == 1 { return !nameInput.isEmpty }
        return true
    }
    
    private func completeOnboarding() {
        store.currentUser.name = nameInput
        store.currentUser.avatarData = selectedAvatarData
        store.currentUser.profession = professionInput
        store.currentUser.bio = bioInput
        
        withAnimation {
            store.hasCompletedOnboarding = true
            selectedTab = 0 // Jump to Feed tab
        }
    }
}
