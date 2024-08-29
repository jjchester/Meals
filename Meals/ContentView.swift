//
//  ContentView.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MealsViewModel
    @State private var searchText = ""

    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return viewModel.meals
        } else {
            return viewModel.meals.filter { meal in
                meal.strMeal.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: MealsViewModel())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(filteredMeals, id: \.idMeal) { meal in
                        NavigationLink(
                            destination: MealDetailView(viewModel: viewModel, mealID: meal.idMeal, cachedImage: ImageCache.shared.object(forKey: meal.strMealThumb as NSString))
                                .navigationTitle("Details")
                                .navigationBarTitleDisplayMode(.inline)
                        ) {
                            MealCardView(viewModel: viewModel, meal: meal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .refreshable {
                    await viewModel.refreshMeals()
                }
                .padding()
            }
            .navigationTitle("Desserts")
            .searchable(text: $searchText, prompt: "Search desserts")
            .onAppear() {
                viewModel.setModelContext(modelContext)
            }
            .task {
                await viewModel.refreshMeals()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    primaryButton: .default(Text("Retry")) {
                        Task {
                            await viewModel.refreshMeals()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
