//
//  Catalog.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import Foundation
import SWXMLHash
import Alamofire

/// The Category class - Singleton
class Catalog {
    
    static let sharedCatalog = Catalog()
    
    /// An ordered dictionary of <Category:[Category]> structs, main categories are the keys, arrays of sub-categories are the values
    private(set) var categories = OrderedDictionary<Category,[Category]>()
    /// An Array of all the products
    private(set) var products = [Product]()
    /// The main product catalog
    private(set) var mainProductCataog: ProductCatalog?
    /// The product cart
    var cart = Cart()
    /// An array of the main categories (the categories dictionary keys)
    var mainCategories: [Category] {
        get {
            return categories.keys
        }
    }
    /// An array of all subcategories (a flatmap of all the subcategory array values of categories dictionary)
    var subCategories: [Category] {
        get {
            return categories.values.values.flatMap{$0}
        }
    }
    /// Constructs a product catalog from a category
    /// - parameter category: The category for constructing the catalog
    /// - returns: A product catalog of the products matching the category
    func productCatalogForCategory(category: Category) -> ProductCatalog {
        var filteredProducts: [Product] = []
        
        // Main category
        if category.parentId == nil {
            filteredProducts.appendContentsOf(self.products.filter { $0.categoryID == category.id })
        } else { // Sub category
            let _ = self.categories[category]?.map { (subCategory) in filteredProducts.appendContentsOf(self.products.filter { $0.categoryID == subCategory.id }) }
        }
        
        return ProductCatalog(products: filteredProducts, sliderCapacity: 3)
    }
}

extension Catalog {
    /// Loads the XML from a given path
    /// - parameter resourcePath: The path to the XML - local or remote
    /// - parameter completion: A completion handler for when the parsing is done - returns an error or nil
    func loadXML(resourcePath: String, completion: ((error: NSError?) -> Void)!) {
        if resourcePath.hasPrefix("http") {
            // Remote XML
            Alamofire.request(.GET, resourcePath, parameters: ["type": "getdata", "user_id": AppConstants.userId, /*"items_in_page": "10", "page_number": "1"*/])
                .validate()
                .responseData { response in
                    switch response.result {
                    case .Success:
                        self.parseXML(response.result.value!, completion: completion)
                    case .Failure(let error):
                        completion(error: error)
                        print(error)
                    }
            }
            
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let url = NSBundle.mainBundle().URLForResource(resourcePath, withExtension: "xml") {
                    
                    if let xmlData = NSData(contentsOfURL: url) {
                        self.parseXML(xmlData, completion: completion)
                    }
                }
            }
        }
    }
    /// XML parsing form the loaded XML file - constructs the Catalog form the XML data
    /// - parameter xmlData: the loaded(local) or downloaded(remote) xml data
    /// - parameter completion: completion callback closure - returns error or nil
    func parseXML(xmlData: NSData, completion: ((error: NSError?) -> Void)!) {
        let xmlCatalog = SWXMLHash.parse(xmlData)["xml"]
        
        self.buildCategoryHierarchy(xmlCatalog["categories"]["category"]
            .map({Category($0)}).sort {$0.id < $1.id})
        
        var sliderProducts = xmlCatalog["products"]["product"]
            .map({Product($0)})
        sliderProducts.removeAll()
        for elem in xmlCatalog["products"]["product"] {
            //print(elem["show_in_slider"].element?.text)
            if elem["show_in_slider"].element?.text == "1" {
                sliderProducts.append(Product(elem))
            }
        }
//        xmlCatalog["products"]["product"].all.map { elem in
//            elem["show_in_slider"].element!.text!
//        }
        var allProducts = Array(sliderProducts)
        allProducts.appendContentsOf(xmlCatalog["products"]["product"]
            .map({Product($0)}))
        self.products = allProducts
        self.mainProductCataog = ProductCatalog(products: self.products, sliderCapacity: sliderProducts.count)
        //UIImageView.cacheLocalProductImages(self.products)
        
        if completion != nil {
            dispatch_async(dispatch_get_main_queue()) {
                completion(error: nil)
            }
        }
    }
    /// Builds the category heirarchy (populates the categories ordered dictionary) of main : [sub-categories]
    /// - param categoriesParam: an array of categories
    func buildCategoryHierarchy(categoriesParam: [Category]) {
        let _ = categoriesParam
            .map { (mainCategory) in
                if (mainCategory.parentId == nil)  {
                    categories[mainCategory] =  categoriesParam.filter { $0.parentId == mainCategory.id
                    }
                }
        }
    }
}
