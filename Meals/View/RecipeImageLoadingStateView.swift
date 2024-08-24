//
//  RecipeImageLoadingState.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import SwiftUI

struct RecipeImageLoadingStateView: View {
    @State private var startAngle: Angle = .zero
    private let animationDuration: Double = 1.5

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(AngularGradient(
                    gradient: Gradient(colors: [.gray.opacity(0.2), .gray]),
                    center: .center,
                    startAngle: startAngle,
                    endAngle: startAngle + .degrees(360)
                ), lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(startAngle)
                .animation(
                    Animation.linear(duration: animationDuration)
                        .repeatForever(autoreverses: false),
                    value: startAngle
                )
        }
        .onAppear {
            startAngle = .degrees(360)
        }
    }
}
