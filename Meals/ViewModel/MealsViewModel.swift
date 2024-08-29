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
    @Published var favorites: [String] = []
    @Published var errorMessage: String? = nil
    
    private var modelContext: ModelContext?
    private let favoritesKey = "favoriteMealIds"

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadStoredMeals()
        loadFavorites()
        Task {
            await refreshMeals()
        }
    }
    
    private func loadStoredMeals() {
        guard let modelContext = modelContext else { return }
        do {
            let fetchedMeals = try fetchStoredMeals(from: modelContext)
            setMeals(fetchedMeals)
        } catch {
            handleError("Failed to fetch stored meals.")
        }
    }
    
    func refreshMeals() async {
        guard let modelContext = modelContext else { return }
        do {
            let fetchedMeals = try await APIService.shared.fetchDessertMeals()
            let updatedMeals = try updateMeals(with: fetchedMeals, in: modelContext)
            setMeals(updatedMeals)
            preloadImages(for: updatedMeals)
        } catch {
            handleError("Failed to fetch meals.")
        }
    }
    
    func loadMealDetails(mealID: String) async throws -> MealDetail? {
        do {
            let details = try await APIService.shared.fetchMealDetails(mealID: mealID)
            return details
        } catch {
            handleError("Failed to fetch meal details.")
            return nil
        }
    }
    
    private func fetchStoredMeals(from context: ModelContext) throws -> [Meal] {
        let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.strMeal)])
        return try context.fetch(descriptor)
    }
    
    private func updateMeals(with fetchedMeals: [Meal], in context: ModelContext) throws -> [Meal] {
        let existingMeals = try fetchStoredMeals(from: context)
        var updatedMeals: [Meal] = []

        for fetchedMeal in fetchedMeals {
            if let existingMeal = existingMeals.first(where: { $0.idMeal == fetchedMeal.idMeal }) {
                existingMeal.strMeal = fetchedMeal.strMeal
                existingMeal.strMealThumb = fetchedMeal.strMealThumb
                updatedMeals.append(existingMeal)
            } else {
                let newMeal = Meal(idMeal: fetchedMeal.idMeal, strMeal: fetchedMeal.strMeal, strMealThumb: fetchedMeal.strMealThumb)
                context.insert(newMeal)
                updatedMeals.append(newMeal)
            }
        }

        try context.save()
        return updatedMeals
    }

    private func preloadImages(for meals: [Meal]) {
        meals.forEach { preloadImage(for: $0) }
    }
    
    private func preloadImage(for meal: Meal) {
        guard let url = URL(string: meal.strMealThumb) else { return }
        if ImageCache.shared.object(forKey: url.absoluteString as NSString) != nil {
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
    
    private func setMeals(_ meals: [Meal]) {
        self.meals = meals
        self.errorMessage = nil
    }
    
    private func handleError(_ message: String) {
        self.errorMessage = message
        print(message)
    }
    
    private func loadFavorites() {
        let savedFavorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] ?? []
        favorites = savedFavorites
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
        loadFavorites()
    }

    func toggleFavorite(for mealID: String) {
        if let index = favorites.firstIndex(of: mealID) {
            favorites.remove(at: index)
        } else {
            favorites.append(mealID)
        }
        saveFavorites()
    }
    
    func isFavorite(_ mealID: String) -> Bool {
        return favorites.contains(mealID)
    }
}
