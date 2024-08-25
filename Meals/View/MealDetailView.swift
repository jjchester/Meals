//
//  MealDetailView.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI

struct MealDetailView: View {
    @StateObject private var viewModel = MealsViewModel()
    let mealID: String
    let cachedImage: UIImage?
    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
            if let meal = viewModel.selectedMeal {
                ScrollView {
                    if let cachedImage = cachedImage {
                        Image(uiImage: cachedImage)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    } else {
                        AsyncImage(url: URL(string: meal.strMealThumb)) { image in
                            image
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RecipeImageLoadingStateView()
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding()
                    }

                    Text(meal.strMeal)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    VStack(spacing: 8) {
                        Text("Ingredients")
                            .font(.headline)
                            .padding(.bottom)

                    LazyVGrid(columns: columns, alignment: .center) {
                        ForEach(meal.ingredients.keys.sorted(), id: \.self) { key in
                            VStack {
                                Text(key)
                                    .font(.subheadline)
                                    .bold()
                                Text(meal.ingredients[key] ?? "")
                                    .font(.subheadline)
                            }
                            .padding([.bottom])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()

                Text("Instructions")
                    .font(.headline)
                    .padding(.top)

                Text(meal.strInstructions)
                    .padding(.horizontal)
            }
        } else {
            RecipeImageLoadingStateView()
                .task {
                    await viewModel.loadMealDetails(mealID: mealID)
                }
        }
    }
}
