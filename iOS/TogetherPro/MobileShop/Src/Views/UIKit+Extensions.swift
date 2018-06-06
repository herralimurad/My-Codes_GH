//
//  UIKit+Extensions.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import AlamofireImage

/* UIKit elements and Foundation class extensions for utility and additional functionality.
*/

// MARK: CollectionType+LettersAndNumbers
extension CollectionType where Generator.Element == String {
    static func uppercaseLettersArray() -> [String] {
        var lettersArray = UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
        lettersArray.removeLast()
        return lettersArray
    }
    
    static func numbersArray() -> [String] {
        var numbersArray: [String] = []
        for number in (0...9) {
            numbersArray.append(String(number))
        }
        return numbersArray
    }
}

// MARK:
// MARK: Array+RandomIndex
extension Array {
    var randomIndex: Int {
        get {
           return startIndex.advancedBy(Int(arc4random_uniform(UInt32(count))))
        }
    }
}

// MARK:
// MARK: String+RandomAlphanumericString
extension String {
    static func randomAlphaNumericString(length: Int) -> String {
        let letters = Array.uppercaseLettersArray()
        let numbers = Array.numbersArray()
        var resultString = ""
        
        for index in (0..<length) {
            if index%2 == 0 {
                let letterIndex = letters.randomIndex
                resultString += (letters[letterIndex])
                
            } else {
                let numIndex = numbers.randomIndex
                resultString += (numbers[numIndex])
            }
        }
        
        return resultString
    }
    
    static func currentDateString(format format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(NSDate())
    }
}

// MARK:
// MARK: String+NetworkResource
extension String {
    var networkResource: Bool {
        return self.hasPrefix("http")
    }
}

// MARK:
// MARK: UITableView+Expandable
extension UITableView {
    func expandSection(section: Int) {
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section)
        
        guard numberOfRows != nil else { return }
        
        var indexesPathToInsert:[NSIndexPath] = []
        
        for i in (1..<numberOfRows!) {
            indexesPathToInsert.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        if indexesPathToInsert.count > 0 {
            self.beginUpdates()
            self.insertRowsAtIndexPaths(indexesPathToInsert, withRowAnimation: .Fade)
            self.endUpdates()
        }
    }
    
    func collapseSection(section: Int, completion: (() -> Void)!) {
        
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section)
        var indexesPathToDelete:[NSIndexPath] = []
        
        for i in (1..<numberOfRows!) {
            indexesPathToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        if indexesPathToDelete.count > 0 {
            self.beginUpdates()
            self.deleteRowsAtIndexPaths(indexesPathToDelete, withRowAnimation: .Fade)
            if completion != nil {
                completion()
            }
            self.endUpdates()
        }
    }
}

// MARK:
// MARK: UINavigationBar+Borderless
extension UINavigationBar {
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.hideBottomHairline()
    }
    
    func hideBottomHairline() {
        if let navigationBarImageView = hairlineImageViewInNavigationBar(self) {
            navigationBarImageView.hidden = true
        }
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
}

// MARK:
// MARK: UIImageView+ReapplyTintColor
extension UIImageView {
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let tintColor = self.tintColor
        self.tintColor = nil
        self.tintColor = tintColor
    }
}

// MARK:
// MARK: UIImageView+AssetsCache
extension UIImageView {
    class func cacheLocalProductImages(products: [Product]) {
        let _ =  products.map() { product in
            if !product.networkResource {
                
                UIImageView.af_sharedImageDownloader.imageCache
                let dummyRequest = NSURLRequest(URL: NSURL(fileURLWithPath: product.photo))
                let originalImage = Image(named: product.photo)
                
                for columnCount in 1...3 {
                    let resizedImage = resizedImageForColumnCount(originalImage!, columnCount: columnCount)
                    
                    UIImageView.af_sharedImageDownloader.imageCache?.addImage(resizedImage.image, forRequest: dummyRequest, withAdditionalIdentifier: resizedImage.identifier)
                }
            }
        }
    }
    
    class func resizedImageForColumnCount(image: Image, columnCount: Int) -> (image: Image, identifier: String) {
        var imageSize = image.size
        
        if columnCount == 1 {
            let imageHeight = MainIntefaceViewControllerConstants.singleProductRowHeight - 10.0
            let scaleRatio = image.size.height/imageHeight
            let scaledWidth = image.size.width/scaleRatio
            
            imageSize = CGSizeMake(scaledWidth, imageHeight)
            
        } else {
            let padding: CGFloat = (CGFloat(columnCount) + 1) * 8.0
            let imageWidth = round((UIScreen.mainScreen().bounds.size.width - padding) / CGFloat(columnCount))
            let scaleRatio = image.size.width/imageWidth
            let scaledHeigth = image.size.height/scaleRatio
            
            imageSize = CGSizeMake(imageWidth, scaledHeigth)
        }
        
        return (image.af_imageAspectScaledToFillSize(imageSize) , "\(columnCount)")
    }
    
    func setImageWithPath(imagePath: String, cacheIdentifier: String = "THUMB") {
        
        if imagePath.hasPrefix("http") {
            if let url = NSURL(string: imagePath) {
                let placeholderImage = Image(named: "menu_logo")
                self.af_setImageWithURL(url, placeholderImage: placeholderImage, filter: AspectScaledToFillSizeFilter(size: self.frame.size))
            }
            
        } else {
            
            let dummyRequest = NSURLRequest(URL: NSURL(fileURLWithPath: imagePath))
            
            if let cachedProductPhoto = UIImageView.af_sharedImageDownloader.imageCache?.imageForRequest(dummyRequest, withAdditionalIdentifier:cacheIdentifier) {
                self.image = cachedProductPhoto
            } else {
                if let productPhoto = Image(named: imagePath) {
                    let thumbnailPhoto = productPhoto.af_imageAspectScaledToFillSize(self.frame.size)
                    self.image = thumbnailPhoto
                    UIImageView.af_sharedImageDownloader.imageCache?.addImage(thumbnailPhoto, forRequest: dummyRequest, withAdditionalIdentifier: cacheIdentifier)
                }
            }
        }
    }
}

// MARK:
// MARK: MarginTextField
class MarginTextField:  UITextField {
    internal override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(super.textRectForBounds(bounds), 8, 0)
    }
    
    internal override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
    
    internal override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
