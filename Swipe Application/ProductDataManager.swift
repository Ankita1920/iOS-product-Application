//
//  ProductDataManager.swift
//  Swipe Application
//
//  Created by Ankita Mondal on 11/05/24.
//

import Foundation

class ProductDataManager {
    
    static let shared = ProductDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let productKey = "Products"
    
    func saveProducts(_ products: [Product]) {
        let encodedData = try? JSONEncoder().encode(products)
        userDefaults.set(encodedData, forKey: productKey)
    }
    
    func loadProducts() -> [Product] {
        guard let encodedData = userDefaults.data(forKey: productKey),
              let products = try? JSONDecoder().decode([Product].self, from: encodedData) else {
            return []
        }
        return products
    }
}
