//
//  Category.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import Foundation
import SWXMLHash

/// the Category struct
public struct Category: Hashable {
    /// Category id
    let id: Int
    /// Parent id (optional - main categories don't have parentID)
    let parentId: Int?
    /// Category title
    let title: String
    
    public var hashValue: Int {
        return title.hashValue ^ id.hashValue
    }
    
    init(_ xmlIndexer:XMLIndexer) {
        id = Int((xmlIndexer["category_id"].element?.text)!)!
        //id = Int((xmlIndexer.element?.attributes["category_id"]!)!)!
        title = (xmlIndexer["category_name"].element?.text)!
        
        //xmlIndexer.element?.attributes["parent_Id"]
        if let pId = xmlIndexer["parent_id"].element?.text {
            if Int(pId) != 0 {
                parentId = Int(pId)
            }
            else {
                parentId = nil
            }
        } else {
            parentId = nil
        }
    }
}

public func ==(lhs: Category, rhs: Category) -> Bool {
    return (lhs.id == rhs.id)
}
