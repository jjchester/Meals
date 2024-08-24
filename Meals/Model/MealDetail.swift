//
//  MealDetail.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import Foundation

struct MealDetailResponse: Decodable {
    let meals: [MealDetail]
}

struct MealDetail: Decodable {
    let strMeal: String
    let strInstructions: String
    let strMealThumb: String
    let ingredients: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case strMeal, strInstructions, strMealThumb
        
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
        
        var tempIngredients: [String: String] = [:]
        
        for i in 1...10 {
            if let ingredient = try container.decodeIfPresent(String.self, forKey: CodingKeys(rawValue: "strIngredient\(i)")!)?.trimmingCharacters(in: .whitespacesAndNewlines), !ingredient.isEmpty {
                let measure = try container.decodeIfPresent(String.self, forKey: CodingKeys(rawValue: "strMeasure\(i)")!)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                tempIngredients[ingredient] = measure
            }
        }
        
        ingredients = tempIngredients
    }
}
