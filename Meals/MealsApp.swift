//
//  MealsApp.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI

@main
struct MealsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Meal.self)
    }
}
