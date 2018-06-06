//
//  ProductsLayout.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import Foundation
/// The ProductsLayout struct
struct ProductsLayout: Hashable {
    /// An array of the products layout (2D array of Products in 1,2 or 3 in a row)
    var products = [[Product]]()
    
    var hashValue: Int {
        let flatProducts = products.flatten()
        if let firstProduct = flatProducts.first {
            return flatProducts.count.hashValue ^ firstProduct.title.hashValue
        }
        
        return flatProducts.count.hashValue
    }
}

func ==(lhs: ProductsLayout, rhs: ProductsLayout) -> Bool {
    let flatLhsProducts = lhs.products.flatten()
    let flatRhsProducts = rhs.products.flatten()
    
    return flatLhsProducts.count == flatRhsProducts.count && flatLhsProducts.first == flatRhsProducts.first
}
