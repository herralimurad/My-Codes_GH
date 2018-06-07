//
//  Cart.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit

/// Cart error enum
enum CartError: ErrorType {
    /// The product already exists in the cart
    case AleradyExistsError(String)
    /// The car is empty
    case CartIsEmptyError(String)
}
/// The Cart struct
struct Cart {
    /// All the products in the cart
    var products = [Product]()
    /// Checks if the cart is empty
    private var isEmpty: Bool {
        get {
            return products.isEmpty
        }
    }
    /// Calculates the saved amount for all the products in the cart (normal - discounted price)*quantity
    var savedAmount: Double {
        get {
            return products.reduce(0.0) {
                if $1.discountedPrice != nil  {
                    return $0 + ((Double($1.quantity) * ($1.price - $1.discountedPrice!)))
                }
                
                return $0
            }
        }
    }
    /// The subtotal of all the products in the cart (total - vat amount)
    var subTotalAmout: Double {
        get {
            return totalAmount - vatAmount
        }
    }
    /// the vat amount (calculated based on the var constant in AppSettings)
    var vatAmount: Double {
        get {
           return totalAmount - (totalAmount / (1+AppConstants.VAT))
        }
    }
    /// The total amount of all the products (currentPrice*quantity)
    var totalAmount: Double {
        get {
            return products.reduce(0.0) {
                return $0 + (Double($1.quantity) * $1.currentPrice)
            }
        }
    }
}

extension Cart {
    /// Adds a product to the cart
    /// - parameter: a product to add
    /// - throws: AlreadyExists error
    mutating func addProuctToCart(inout product: Product) throws {
        guard !products.contains(product) else {
            var cartError = "This product already exists in your cart."
            
            if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                cartError = appSettings["existing_product_in_cart"] as! String
            }
            throw CartError.AleradyExistsError(cartError)
        }
        
        product.quantity += 1
        products.append(product)
    }
    /// Checks if the cart can be opened
    /// - throws: CartIsEmptyError if the cart is empty
    func canOpenCart() throws -> Bool {
        if isEmpty {
            var cartError = "Please add at least one item to your cart"
            
            if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                cartError = appSettings["no_cart_items"] as! String
            }
            throw CartError.CartIsEmptyError(cartError)
        }
        
        return false
    }
}
