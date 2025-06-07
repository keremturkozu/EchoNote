//
//  EchoNoteApp.swift
//  EchoNote
//
//  Created by Kerem Türközü on 7.06.2025.
//

import SwiftUI
import SwiftData

@main
struct EchoNoteApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VoiceNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
