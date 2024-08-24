//
//  MealsViewModel.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI
import SwiftData

@MainActor
class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var selectedMeal: MealDetail?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadStoredMeals()
        Task {
            await refreshMeals()
        }
    }
    
    private func loadStoredMeals() {
        guard let modelContext = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.strMeal)])
            self.meals = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch stored meals: \(error)")
        }
    }
    
    func refreshMeals() async {
        guard let modelContext = modelContext else { return }
        do {
            let fetchedMeals = try await APIService.shared.fetchDessertMeals()
            
            // Fetch all existing meals
            let descriptor = FetchDescriptor<Meal>()
            let existingMeals = try modelContext.fetch(descriptor)
            
            var updatedMeals: [Meal] = []
            
            for fetchedMeal in fetchedMeals {
                // If we find an exisitng meal, update it with new info, and if not, create a new meal entry
                if let existingMeal = existingMeals.first(where: { $0.idMeal == fetchedMeal.idMeal }) {
                    existingMeal.strMeal = fetchedMeal.strMeal
                    existingMeal.strMealThumb = fetchedMeal.strMealThumb
                    updatedMeals.append(existingMeal)
                } else {
                    let newMeal = Meal(idMeal: fetchedMeal.idMeal, strMeal: fetchedMeal.strMeal, strMealThumb: fetchedMeal.strMealThumb)
                    modelContext.insert(newMeal)
                    updatedMeals.append(newMeal)
                }
            }
            
            // Save changes
            try modelContext.save()
            
            // Update published property
            self.meals = updatedMeals
            
            for meal in self.meals {
                preloadImage(for: meal)
            }
        } catch {
            print("Failed to refresh meals: \(error)")
        }
    }
    
    func loadMealDetails(mealID: String) async {
        do {
            selectedMeal = try await APIService.shared.fetchMealDetails(mealID: mealID)
        } catch {
            print("Failed to load meal details: \(error)")
        }
    }
    
    private func preloadImage(for meal: Meal) {
        guard let url = URL(string: meal.strMealThumb) else { return }
        
        // Return if image exists in cache
        if let _ = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: meal.strMealThumb as NSString)
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
