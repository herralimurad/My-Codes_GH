//
//  ProductCatalog.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import Foundation

extension Int {
    /// Generates a random in in a given range
    /// - parameter range: The given range (closed from both sides)
    /// - returns: a random uniform int
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

/// The ProductCatalog struct
struct ProductCatalog: Equatable {
    /// All the products in the product catalog
    let allProducts: [Product]!
    /// The allProducts - slider products in the product catalog
    let products: [Product]!
    /// The product layout of the catalog
    var productsLayout = ProductsLayout()
    /// The slider products
    let sliderProducts: [Product]!
    
    init(products:[Product], sliderCapacity:Int) {
        self.allProducts = products
        
        let distributedProducts = generateProductsDistribution(self.allProducts,
            sliderCapacity: sliderCapacity)
        
        self.sliderProducts = distributedProducts.sliderProducts
        self.products = distributedProducts.products
        self.productsLayout.products = generateProductLayout(self.products)
    }
}

func ==(lhs: ProductCatalog, rhs: ProductCatalog) -> Bool {
    return lhs.allProducts == rhs.allProducts
}

/// Generates a random distribution of the products 
/// - returns: a products + slider products tuple
func generateProductsDistribution(productsArray:[Product], sliderCapacity: Int)
    -> (products:[Product], sliderProducts:[Product]) {
    
    if productsArray.count > 0 {
        
        if sliderCapacity == 0 {
            return (productsArray,[])
        }
        
        if productsArray.count <= sliderCapacity {
            return ([], productsArray)
        }
        
        let sliderProducts = Array(productsArray[0..<sliderCapacity])
        let range = sliderProducts.count..<productsArray.count
        let leftOverProducts = Array(productsArray[range])
        
        return (leftOverProducts, sliderProducts)
    }
    
    return ([],[])
}
/// Generates a random products layout (1,2 or 3 products per row)
/// - parameter productsArray: an array of products
/// - returns: 2D products array with 1,2 or 3 products per row distribution
func generateProductLayout(productsArray:[Product]) -> [[Product]] {
    
    var pArray = productsArray
    
    if pArray.count > 0 {
        var layoutArray = Array<Array<Product>>()
        
        while pArray.count > 3 {
            let randInt = Int.random(0...2)
            
            let currentSelection = Array(pArray[0...randInt])
            layoutArray.append(currentSelection)
            
            pArray.removeRange(0..<currentSelection.count)
        }
        
        switch pArray.count {
        case 1: layoutArray.append([pArray[0]])
        case 2: layoutArray.append([pArray[0], pArray[1]])
        case 3: layoutArray.append([pArray[0], pArray[1],
            pArray[2]])
            
        default:
            break
        }
        
        return layoutArray
    }
    
    return []
}
