//
//  ContentView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BehindTheWorkView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("EXPLORE")
                }
            CreateView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("CREATE")
                }
            BoardView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("SAVED")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("PROFILE")
                }
        }
        .tint(Color("AppPurple"))
    }
}

#Preview {
    ContentView()
}
