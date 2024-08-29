//
//  MealCardView.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI

struct MealCardView: View {
    private let meal: Meal
    @ObservedObject private var viewModel: MealsViewModel

    public init(viewModel: MealsViewModel, meal: Meal) {
        self.viewModel = viewModel
        self.meal = meal
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack {
                if let cachedImage = ImageCache.shared.object(forKey: meal.strMealThumb as NSString) {
                    Image(uiImage: cachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                } else {
                    AsyncImage(url: URL(string: meal.strMealThumb)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    } placeholder: {
                        RecipeImageLoadingStateView()
                    }
                }
                
                Text(meal.strMeal)
                    .font(.headline)
                    .padding(.leading, 10)
                Button(action: {
                    viewModel.toggleFavorite(for: meal.idMeal)
                }) {
                    Image(systemName: viewModel.isFavorite(meal.idMeal) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(meal.idMeal) ? .red : .gray)
                }
                .padding(.trailing, 10)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
        }
    }
}
