//
//  iosEmotionApp.swift (Don't touch)
//  iosEmotion
//
//  Created by Hedy on 20/4/2026.
//

import SwiftUI

@main
struct iosEmotionApp: App {
    @StateObject private var postStore = PostStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(postStore)
        }
    }
}


struct iosThingApp: App{
    var body: some Scene{
        WindowGroup{
            
            ContentView()
            
        }
    }
}
