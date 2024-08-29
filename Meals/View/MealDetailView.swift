//
//  MealDetailView.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI

struct MealDetailView: View {
    @ObservedObject private var viewModel: MealsViewModel
    let mealID: String
    let cachedImage: UIImage?
    private let columns = [GridItem(.adaptive(minimum: 150))]

    public init(viewModel: MealsViewModel, mealID: String, cachedImage: UIImage?) {
        self.viewModel = viewModel
        self.mealID = mealID
        self.cachedImage = cachedImage
    }
    
    var body: some View {
            if let meal = viewModel.selectedMeal {
                ScrollView {
                    if let cachedImage = cachedImage {
                        ZStack(alignment: .bottomTrailing) {

                        Image(uiImage: cachedImage)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            Button(action: {
                                viewModel.toggleFavorite(for: mealID)
                            }) {
                                Image(systemName: viewModel.isFavorite(mealID) ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isFavorite(mealID) ? .red : .gray)
                                    .padding(10)
                                    .background(Circle().fill(Color.white))
                            }
                            .padding([.bottom, .trailing], 20)
                        }
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
