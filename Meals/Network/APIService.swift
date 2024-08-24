//
//  APIService.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

class APIService {
    static let shared = APIService()
    private init() {}

    func fetchDessertMeals() async throws -> [Meal] {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals.sorted { $0.strMeal < $1.strMeal }
    }

    func fetchMealDetails(mealID: String) async throws -> MealDetail {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let mealDetailResponse = try JSONDecoder().decode(MealDetailResponse.self, from: data)
        return mealDetailResponse.meals.first!
    }
}
