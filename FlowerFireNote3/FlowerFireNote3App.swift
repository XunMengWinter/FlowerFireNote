//
//  FlowerFireNote3App.swift
//  FlowerFireNote3
//
//  Created by ice on 12/6/26.
//

import SwiftUI
import SwiftData

@main
struct FlowerFireNote3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FavoritePost.self)
    }
}
