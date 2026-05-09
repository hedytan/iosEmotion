//
//  ContentView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PostStore
    @State private var selectedTab: Int = 0
    
    var body: some View {
        if !store.hasCompletedOnboarding {
            OnboardingView(selectedTab: $selectedTab)
        } else {
            TabView(selection: $selectedTab) {
                BehindTheWorkView()
                    .tabItem {
                        Image(systemName: "safari")
                        Text("EXPLORE")
                    }
                    .tag(0)
                
                CreateView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("CREATE")
                    }
                    .tag(1)
                
                BoardView()
                    .tabItem {
                        Image(systemName: "bookmark")
                        Text("SAVED")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("PROFILE")
                    }
                    .tag(3)
            }
            .tint(Color("AppPurple"))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PostStore())
}
