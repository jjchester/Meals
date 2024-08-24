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
        VStack {
            if let meal = viewModel.selectedMeal {
                ScrollView {
                    if let cachedImage = cachedImage {
                        Image(uiImage: cachedImage)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
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
                        .padding()
                    }

                    Text(meal.strMeal)
                        .font(.largeTitle)

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
}
