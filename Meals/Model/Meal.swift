//
//  Meal.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import Foundation

struct MealsResponse: Decodable {
    let meals: [Meal]
}

import SwiftData

@Model
class Meal: Decodable {
    @Attribute(.unique) var idMeal: String
    var strMeal: String
    var strMealThumb: String
    
    enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strMealThumb
    }
    
    init(idMeal: String, strMeal: String, strMealThumb: String) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strMealThumb = strMeal
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
    }
}
