//
//  ImageCache.swift
//  Meals
//
//  Created by Justin Chester on 2024-08-23.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
