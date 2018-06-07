//
//  MainInterfaceViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import KYDrawerController
import AlamofireImage
import PagedHorizontalView
import DTIToastCenter
import SWXMLHash

struct MainIntefaceViewControllerConstants {
    static let openCartSegueIdenfifier = "OpenCart"
    static let showProductDetailsSegueIdentifier = "ShowProductDetails"
    
    static let productCellIdentifier = "ProductCell"
    static let sliderCellIdentifier = "SliderCell"
    
    static let singleProductRowHeight: CGFloat = 140
    static let doubleProductRowHeight: CGFloat = 160
    static let tripleProductRowHeight: CGFloat = 200
}

class MainInterfaceViewController: UIViewController {
    
    @IBOutlet var leftNavigationButtons: [UIBarButtonItem]!
    @IBOutlet var rightNavigationButtons: [UIBarButtonItem]!
    
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var slider: PagedHorizontalView!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var selectLanguageButton: UIButton!
    @IBOutlet weak var aboutView: UIView!
    
    var doneButton: UIBarButtonItem!
    
    
    var searchController: UISearchController!
    
    var productCatalog = Catalog.sharedCatalog.mainProductCataog {
        didSet {
            table.reloadData()
            slider.collectionView.reloadData()
            slider.currentIndex = 0
            slider.moveToPage(0, animated: false)
            
            navigationItem.rightBarButtonItems = rightNavigationButtons
            menuView.hidden = true
            
            if productCatalog == Catalog.sharedCatalog.mainProductCataog {
                title = nil
                searchButton.setTitle(nil, forState: .Normal)
                searchButton.setImage(UIImage(named: "search"), forState: .Normal)
            } else {
                searchButton.setTitle("Clear", forState: .Normal)
                searchButton.setImage(nil, forState: .Normal)
            }
            
            searchButton.sizeToFit()
        }
    }
    
    var menuViewType = "" {
        didSet {
            title = menuViewType
            navigationItem.rightBarButtonItems = []
            var buttonTitle = "Done"
            var menuType = "Settings"
            
            
            if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                buttonTitle = appSettings["done"] as! String
                menuType = appSettings["action_settings"] as! String
            }
            
            doneButton = UIBarButtonItem(title: buttonTitle, style: .Plain, target: self, action: #selector(MainInterfaceViewController.doneButtonTapped))
            self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
            
            if menuViewType == menuType {
                menuView.hidden = false
                aboutView.hidden = true
            } else {
                menuView.hidden = true
                aboutView.hidden = false
            }
            
            searchButton.sizeToFit()
        }
    }
    
    func doneButtonTapped() {
        productCatalog = Catalog.sharedCatalog.mainProductCataog
        menuView.hidden = true
        aboutView.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productCatalog = Catalog.sharedCatalog.mainProductCataog
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            languageLabel.text = appSettings["stng1"] as? String
            selectLanguageButton.setTitle(appSettings["stng2"] as? String, forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cartButton.setTitle("\(Catalog.sharedCatalog.cart.products.count)", forState: .Normal)
    }
    
    func loadStringsData(resourcePath: String) {
        if let url = NSBundle.mainBundle().URLForResource(resourcePath, withExtension: "xml") {
            if let xmlData = NSData(contentsOfURL: url) {
                let xmlCatalog = SWXMLHash.parse(xmlData)
                //print(xmlCatalog)
                
                var appSettings = [String: String]()
                
                
                for elem in xmlCatalog["resources"]["string"].all {
                    print(elem.element?.attributes["name"])
                    print(elem.element?.text)
                    
                    appSettings[(elem.element?.attributes["name"])!] = elem.element?.text
                }
                
                NSUserDefaults.standardUserDefaults().setObject(appSettings, forKey: "appSettings")
            }
        }
    }
}

extension MainInterfaceViewController: UISearchControllerDelegate {
    @IBAction func drawerButtonTapped(sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Opened, animated: true)
        }
    }
    
    @IBAction func searchButtonTapped(sender: UIButton) {
        if sender.currentTitle != nil {
            // Clear
            productCatalog = Catalog.sharedCatalog.mainProductCataog
            
        } else {
            
            let searchResultsController = UIStoryboard(name: "Search", bundle: nil).instantiateInitialViewController() as! SearchResultsViewController
            searchResultsController.mainInterfaceVC = self
            // Create the search controller and make it perform the results updating.
            searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.searchResultsUpdater = searchResultsController
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.delegate = self
            
            // Include the search bar within the navigation bar.
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = nil
            navigationItem.titleView = searchController.searchBar
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
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
    
    func willDismissSearchController(searchController: UISearchController) {
        navigationItem.titleView = nil
        navigationItem.leftBarButtonItems = leftNavigationButtons
        navigationItem.rightBarButtonItems = rightNavigationButtons
    }
    
    @IBAction func selectLanguageButtonTapped(sender: AnyObject) {
        var languageStr: String
        var alertTitle = "Change app language?"
        var alertSubTitle = "App content will be changed to Arabic language"
        var cancelButtonTitle = "Cancel"
        var otherButtonTitle = "Yes, change it!"
        var alertTitleOther = "Changed!"
        var alertSubTitleOther = "App language has been changed!"
        var buttonTitle = "Ok"
        
        
        if let language = NSUserDefaults.standardUserDefaults().stringForKey("language") {
            if language == "English" {
                languageStr = "Arabic"
                alertSubTitle = "App content will be changed to Arabic language"
            }
            else {
                languageStr = "English"
                alertSubTitle = "سيتم تغيير محتوى التطبيق ل لغة الإنجليزية"
            }
        }
        else {
            languageStr = "Arabic"
            alertSubTitle = "سيتم تغيير محتوى التطبيق ل لغة الإنجليزية"
        }
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            alertTitle = appSettings["alert_title"] as! String
            cancelButtonTitle = appSettings["cancel_button_title"] as! String
            otherButtonTitle = appSettings["other_button_title"] as! String
            alertTitleOther = appSettings["alert_title_other"] as! String
            alertSubTitleOther = appSettings["alert_sub_title_other"] as! String
            buttonTitle = appSettings["button_title"] as! String
        }
        
        
        SweetAlert().showAlert(alertTitle, subTitle: alertSubTitle, style: AlertStyle.Warning, buttonTitle:cancelButtonTitle, buttonColor:UIColor.lightGrayColor() , otherButtonTitle: otherButtonTitle, otherButtonColor: UIColor.grayColor()) { (isOtherButton) -> Void in
            if isOtherButton == true {
                print("Cancel Button  Pressed")
            }
            else {
                SweetAlert().showAlert(alertTitleOther, subTitle: alertSubTitleOther, style: AlertStyle.Success, buttonTitle: buttonTitle)
                
                NSUserDefaults.standardUserDefaults().setObject(languageStr, forKey: "language")
                
                if languageStr == "English" {
                    self.loadStringsData("strings (2)")
                }
                else {
                    self.loadStringsData("strings (1)")
                }
                
                if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                    self.title = appSettings["action_settings"] as? String
                    self.doneButton.title = appSettings["done"] as? String
                    self.languageLabel.text = appSettings["stng1"] as? String
                    self.selectLanguageButton.setTitle(appSettings["stng2"] as? String, forState: .Normal)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                    
                }
            }
        }
    }
    
    @IBAction func websiteButtonTapped(sender: UIButton) {
        let URL = "https://www.togetherpro.com"
        UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
    }
}

extension MainInterfaceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        if let products = productCatalog?.productsLayout.products[indexPath.row] {
//            switch products.count {
//            case 1: return MainIntefaceViewControllerConstants.singleProductRowHeight
//            case 2: return MainIntefaceViewControllerConstants.doubleProductRowHeight
//            default: return MainIntefaceViewControllerConstants.tripleProductRowHeight
//            }
//        }
        
        return MainIntefaceViewControllerConstants.singleProductRowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
            
            if let rowsNum = productCatalog?.products.count {
                return rowsNum
            }
            
            return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            var cellIdentifier = MainIntefaceViewControllerConstants.productCellIdentifier
            
            if let products = productCatalog?.products[indexPath.row] {
                
                cellIdentifier = "1" + cellIdentifier
                
                let cell: ProductCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ProductCell
                
                let productTile = cell.productTiles[0]
                productTile.identifier = cellIdentifier
                productTile.product = products
                
                return cell
            } else {
                cellIdentifier = "1" + cellIdentifier
            }
            
            return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
    }
}

extension MainInterfaceViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int {
            
            if let itemsNum = productCatalog?.sliderProducts.count {
                return itemsNum
            }
            
            return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainIntefaceViewControllerConstants.sliderCellIdentifier, forIndexPath: indexPath) as! SliderCell
        
        if let product = productCatalog?.sliderProducts[indexPath.item] {
            cell.productTile.identifier = ""
            cell.productTile.product = product
        }
        
        return cell
    }
}

extension MainInterfaceViewController {
    @IBAction func productTileTapped(sender: ProductTile) {
        performSegueWithIdentifier(MainIntefaceViewControllerConstants.showProductDetailsSegueIdentifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == MainIntefaceViewControllerConstants.showProductDetailsSegueIdentifier {
            let destinationVC = segue.destinationViewController as! ProductDetailsViewController
            
            if let productTile = sender as? ProductTile {
                destinationVC.products = productCatalog?.allProducts
                destinationVC.firstProduct = productTile.product
            } else if let searchResultSender = sender as? SearchResultsViewController {
                destinationVC.products = searchResultSender.visibleResults
                destinationVC.firstProduct = searchResultSender.visibleResults[searchResultSender.tableView.indexPathForSelectedRow!.row]
                destinationVC.title = "\"" + searchResultSender.filterString! + "\""
            }
        }
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            let backItem = UIBarButtonItem()
            backItem.title = appSettings["back"] as? String
            navigationItem.backBarButtonItem = backItem
        }
    }
    
}
