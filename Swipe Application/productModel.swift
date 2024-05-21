//
//  productModel.swift
//  Swipe Application
//
//  Created by Ankita Mondal on 09/05/24.
//

import Foundation
struct Product: Codable {
    let image: String
    let price: Double
    let product_name: String
    let product_type: String
    let tax: Double
}

