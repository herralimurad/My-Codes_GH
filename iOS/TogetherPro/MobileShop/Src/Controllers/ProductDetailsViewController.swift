//
//  ProductCatalogPageViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import PagedHorizontalView
import DTIToastCenter
import Alamofire

class ProductDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var products: [Product]!
    var firstProduct: Product!
    
    // MARKK: outlets
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var pageView: PagedHorizontalView!
    
    // MARK: ViewController lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard firstProduct != nil else {
            return
        }
        
        self.cartButton.setTitle("\(Catalog.sharedCatalog.cart.products.count)", forState: .Normal)
        
        pageView.collectionView.reloadData()
        pageView.layoutIfNeeded()
        
        if let productIndex = products.indexOf(firstProduct) {
            pageView.moveToPage(productIndex, animated: false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Alamofire.request(.POST, AppConstants.XMLRemoteResourcePath, parameters: ["type": "openproduct", "user_id": AppConstants.userId, "product_id": self.firstProduct.id])
                .validate()
                .responseData { response in
                    switch response.result {
                    case .Success:
                        print("Success")
                        
                    case .Failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // Disables swipe to go back gesture
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: CollectionView datasoruce
extension ProductDetailsViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int {
            return products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductDetailsCell", forIndexPath: indexPath) as! ProductDetailsCell
        
        let product = products[indexPath.item]
        cell.product = product
        cell.counterLabel.text = "\(indexPath.item + 1) of \(products.count)"
        cell.addToCartButton.tag = indexPath.item
        cell.layoutIfNeeded()
        
        return cell
    }
}

// MARK: Cart buttons actions
extension ProductDetailsViewController {
    
    @IBAction func openCartButtonTapped(sender: UIButton) {
        do {
            try Catalog.sharedCatalog.cart.canOpenCart()
            performSegueWithIdentifier(MainIntefaceViewControllerConstants.openCartSegueIdenfifier, sender: self)
            
        } catch CartError.CartIsEmptyError(let errorMessage) {
            DTIToastCenter.defaultCenter.makeText(errorMessage)
        } catch {
            print("Unknown error opening cart.")
        }
    }
    
    @IBAction func addToCartButtonTapped(sender: UIButton) {
        do {
            try Catalog.sharedCatalog.cart.addProuctToCart(&products[sender.tag])
            
            incrementRightButtonCount(sender)
            
        } catch CartError.AleradyExistsError(let errorMessage) {
            DTIToastCenter.defaultCenter.makeText(errorMessage)
        } catch {
            print("Unknown error adding product to cart.")
        }
    }
    
    private func incrementRightButtonCount(sender: UIButton) {
        
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.1) {
                self.cartButton.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.8) {
                let scaleTransform = CGAffineTransformMakeScale(0.25, 0.25)
                let translateTransform = CGAffineTransformMakeTranslation(0.0,
                    -CGRectGetMaxY(sender.superview!.frame))
                
                sender.superview!.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
            }
            
            UIView.addKeyframeWithRelativeStartTime(0.9, relativeDuration: 0.1) {
                self.cartButton.transform = CGAffineTransformIdentity
            }
            
            }) { (finished) in
                self.cartButton.setTitle("\(Catalog.sharedCatalog.cart.products.count)", forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            let backItem = UIBarButtonItem()
            backItem.title = appSettings["back"] as? String
            navigationItem.backBarButtonItem = backItem
        }
    }
}
