//
//  Product.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import SWXMLHash

/// The product struct
struct Product: Equatable {
    
    /// Product id
    let id: Int!
    /// Product category id
    let categoryID: Int!
    /// Product price
    let price: Double!
    /// Product discount (optional)
    let discount: Double?
    /// The date
    let date: String!
    /// Product title
    let title: String!
    /// Product description
    let description: String!
    /// Product condition
    let condition: String!
    /// Product color
    let color: String!
    /// Product quantity (default is 0), modified on the cart screen
    var quantity = 0
    
    /// Product status
    let status: String!
    /// Product views
    let views: String!
    /// Product city
    let city: String!
    /// Product district
    let district: String!
    
    var photos: [String]!
    var photo: String {
        return photos.first ?? ""
    }
    
    /// Discounted price
    var discountedPrice: Double? {
        get {
            if let disc = discount {
               return price * (1 - disc/100)
            }
            
            return nil
        }
    }
    
    /// Normal or discounted price
    var currentPrice: Double {
        get {
            guard discountedPrice != nil else {
                return price
            }
            
            return discountedPrice!
        }
    }
    
    /// Product category by categoryID
    var productCategory: Category? {
        get {
            return Catalog.sharedCatalog.mainCategories.filter{$0.id == categoryID}.first
        }
    }
    
    /// Cehcks if product photo is network resource
    var networkResource: Bool {
        return photo.networkResource
    }
    
    init(_ xmlIndexer: XMLIndexer) {
//        id = Int((xmlIndexer.element?.attributes["id"])!)
//        categoryID = Int((xmlIndexer.element?.attributes["category"]!)!)
//        price = Double((xmlIndexer.element?.attributes["price"]!)!)
//        date = xmlIndexer["creation_date"].element?.text
//        title = xmlIndexer["title"].element?.text
//        description = xmlIndexer["description"].element?.text
//        condition = xmlIndexer["condition"].element?.text
//        color = xmlIndexer["color"].element?.text
        
//        photos = xmlIndexer["photos"]["photo"].map { ($0.element?.text!)! }
        
//        if let productDiscount = xmlIndexer.element?.attributes["discount"] {
//            discount = Double(productDiscount)
//        } else {
//            discount = nil
//        }
        
        id = Int((xmlIndexer["product_id"].element?.text)!)
        categoryID = Int((xmlIndexer["product_category"].element?.text)!)
        price = Double((xmlIndexer["price_before_discount"].element?.text)!)
        date = xmlIndexer["creation_date"].element?.text
        title = xmlIndexer["product_name"].element?.text
        description = xmlIndexer["product_note"].element?.text
        condition = xmlIndexer["product_specs"]["product_spec"][0]["spec_value"].element?.text
        color = xmlIndexer["product_specs"]["product_spec"][1]["spec_value"].element?.text
        status = xmlIndexer["product_specs"]["product_spec"][2]["spec_value"].element?.text
        views = xmlIndexer["product_impressions"].element?.text
        city = xmlIndexer["city_name"].element?.text
        district = xmlIndexer["district_name"].element?.text
        
//        for elem in xmlIndexer["product_images"]["product_image"] {
//            print(elem["image_url"].element!.text!)
//        }
//        
//        print(xmlIndexer["product_images"]["product_image"][0]["image_url"])
        
        //photos = xmlIndexer["product_images"]["product_image"][0]["image_url"].map { ($0.element?.text!)! }
        photos = xmlIndexer["product_images"]["product_image"].all.map { elem in
            elem["image_url"].element!.text!
            }
        
        if let productDiscount = xmlIndexer["price_discount_percentage"].element?.text {
            if Double(productDiscount) != 0 {
                discount = Double(productDiscount)
            }
            else {
                discount = nil
            }
        } else {
            discount = nil
        }
    }
}

func ==(lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
}

extension Double {
    /// Double to formatted currency string
    var asCurrencyString: String {
        get {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            formatter.currencySymbol = AppConstants.currency
            return formatter.stringFromNumber(self)!
        }
    }
}
