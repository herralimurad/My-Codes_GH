//
//  CartViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import AlamofireImage
import SnappingStepper

class CartViewController: UIViewController {

    let cartCellIdentifier = "CartCell"
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var subTotalAmountLabel: UILabel!
    @IBOutlet weak var vatAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var savedAmountTitle: UILabel!
    @IBOutlet weak var subTotalAmountTitle: UILabel!
    @IBOutlet weak var vatAmountTitle: UILabel!
    @IBOutlet weak var totalAmountTitle: MainTextColorLabel!
    
    var prototypeCartCell: CartCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.tableFooterView = UIView()
        reloadCartTitles()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadCartAmounts()
    }
    
    func reloadCartAmounts() {
        self.savedAmountLabel.text = Catalog.sharedCatalog.cart.savedAmount.asCurrencyString
        self.subTotalAmountLabel.text = Catalog.sharedCatalog.cart.subTotalAmout.asCurrencyString
        self.vatAmountLabel.text = Catalog.sharedCatalog.cart.vatAmount.asCurrencyString
        self.totalAmountLabel.text = Catalog.sharedCatalog.cart.totalAmount.asCurrencyString
    }
    
    func quantityStepperValueChanged(sender: SnappingStepper) {
        
        let newQuantity = sender.value
        Catalog.sharedCatalog.cart.products[sender.tag].quantity = Int(newQuantity)
        reloadCartAmounts()
    }
    
    func reloadCartTitles() {
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            navigationItem.rightBarButtonItem?.title = appSettings["checkout_other"] as? String
            self.savedAmountTitle.text = appSettings["save"] as? String
            self.subTotalAmountTitle.text = appSettings["subtotal"] as? String
            self.vatAmountTitle.text = (appSettings["vat"] as? String)! + "(20%):"
            self.totalAmountTitle.text = appSettings["total"] as? String
        }
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Catalog.sharedCatalog.cart.products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cartCellIdentifier, forIndexPath: indexPath) as! CartCell
        
        // Remove .ValueChanged event because SnappingStepper triggers the event on value { didSet } for some reason
        cell.quantityStepper.removeTarget(self, action: #selector(CartViewController.quantityStepperValueChanged(_:)), forControlEvents: .ValueChanged)
        
        let product = Catalog.sharedCatalog.cart.products[indexPath.row]
        cell.product = product
        cell.quantityStepper.tag = indexPath.row
        
        // Re-add the .ValueChanged event after cell setup
        cell.quantityStepper.addTarget(self, action: #selector(CartViewController.quantityStepperValueChanged(_:)), forControlEvents: .ValueChanged)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            Catalog.sharedCatalog.cart.products.removeAtIndex(indexPath.row)
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                do {
                    try Catalog.sharedCatalog.cart.canOpenCart()
                    self.reloadCartAmounts()
                    tableView.reloadData() 
                    
                } catch CartError.CartIsEmptyError(_) {
                    self.navigationController?.popViewControllerAnimated(true)
                } catch {
                    print("Unknown error opening cart.")
                }
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            CATransaction.commit()
        }
    }
}

extension CartViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            let backItem = UIBarButtonItem()
            backItem.title = appSettings["back"] as? String
            navigationItem.backBarButtonItem = backItem
        }
    }
}
