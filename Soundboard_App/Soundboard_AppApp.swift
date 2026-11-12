//
//  Soundboard_AppApp.swift
//  Soundboard_App
//
//  Created by Corbett Manser on 11/11/26.
//

import SwiftUI

@main
struct SoundboardApp: App {
    @StateObject private var store = SoundboardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
