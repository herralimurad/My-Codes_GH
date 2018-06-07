//
//  CheckoutTableViewController.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import MessageUI
import SwiftValidator
import DTIToastCenter
import SWXMLHash
import Alamofire

class CheckoutViewController: UIViewController {

    let checkoutCellIdentifier = "CheckoutCell"
    
    let mailComposerVC = MFMailComposeViewController()
    let validator = Validator()
    
    let imagePickerVC = UIImagePickerController()
    var selectedImageURL: NSURL!
    
    
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    @IBOutlet weak var totalValueTitle: UILabel!
    @IBOutlet weak var informationTitle: UILabel!
    @IBOutlet weak var sendOrderButton: UIButton!
    
    var orderSummary: [[String:String]] = []
    var totalValue = 200.0
    
    
    var orderId: String {
        get {
            let currentDate = String.currentDateString(format: AppConstants.orderIdDateFormat)
            let suffix = String.randomAlphaNumericString(AppConstants.orderIdSuffixLength)
            
            return currentDate + "-" + suffix
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalValueLabel.text = Catalog.sharedCatalog.cart.totalAmount.asCurrencyString
        totalValue = Catalog.sharedCatalog.cart.totalAmount
        
        validator.registerField(nameTextField, rules:[RequiredRule()])
        validator.registerField(emailTextField, rules:[RequiredRule()])
        validator.registerField(phoneTextField, rules:[RequiredRule()])
        
        validator.styleTransformers(success: { (validationRule) in
            validationRule.textField.layer.borderWidth = 0
            
            }) { (validationError) in
                validationError.textField.layer.borderColor = UIColor.redColor().CGColor
                validationError.textField.layer.borderWidth = 1
        }
        
        reloadCheckoutTitles()
    }
    
    func reloadCheckoutTitles() {
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            navigationItem.rightBarButtonItem?.title = appSettings["checkout"] as? String
            self.totalValueTitle.text = appSettings["total"] as? String
            self.informationTitle.text = appSettings["fill_info"] as? String
            self.nameTextField.placeholder = appSettings["full_name"] as? String
            self.emailTextField.placeholder = appSettings["e_mail"] as? String
            self.phoneTextField.placeholder = appSettings["phone"] as? String
            self.commentTextView.text = appSettings["comment"] as? String
            self.sendOrderButton.setTitle(appSettings["checkout"] as? String, forState: .Normal)
        }
    }
}

extension CheckoutViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Catalog.sharedCatalog.cart.products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(checkoutCellIdentifier) as! CheckoutCell
        
        let product = Catalog.sharedCatalog.cart.products[indexPath.row]
        cell.titleLabel.text = product.title
        cell.quantityLabel.text = "\(product.quantity)x"
        cell.priceLabel.text = product.currentPrice.asCurrencyString
        
        return cell
    }
}

extension CheckoutViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        guard textView.text != nil else {
            return
        }
        
        var comment = "Comment"
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            comment = appSettings["comment"] as! String
        }
        
        if textView.text! == comment {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        var comment = "Comment"
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            comment = appSettings["comment"] as! String
        }
        
        if textView.text.isEmpty {
            textView.text = comment
        }
    }
}

extension CheckoutViewController: MFMailComposeViewControllerDelegate, ValidationDelegate {
    
    @IBAction func sendOrderButtonTapped(sender: AnyObject) {
        validator.validate(self)
    }
    
    func validationSuccessful() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        var validationError = "Please fill all mandatory fields"
        
        if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
            validationError = appSettings["mandatory_fields"] as! String
        }
        DTIToastCenter.defaultCenter.makeText(validationError)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([AppConstants.mailAddress])
        mailComposerVC.setSubject("Order")
        
        mailComposerVC.setMessageBody(orderBody(), isHTML: false)
        mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        
        return mailComposerVC
    }
    
    func orderBody() -> String {
        var result = ""
        
        result += "Order Number: "
            + orderId + "\n\n"
        
        result += "Name: "
        result += nameTextField.text!
        result += "\n";
        
        result += "E-mail: "
        result += emailTextField.text!
        result += "\n"
        
        result += "Phone: "
        result += phoneTextField.text!
        result += "\n"
        
        if commentTextView.text.characters.count > 0 && commentTextView.text != "Comment" {
            result += "Comment: "
            result += commentTextView.text
            result += "\n"
        }
        
        result += "\n\n"
        
        let _ = Catalog.sharedCatalog.cart.products.map {
            result += $0.title
            result += "\t\t\t\t\t"
            result += "\($0.quantity)x"
            result += "\t\t\t"
            result += $0.currentPrice.asCurrencyString
            result += "\n"
            
            let order = ["product": "\($0.id)", "quantity": "\($0.quantity)"]
            orderSummary.append(order)
        }
        
        result += "\n\n"
        
        result += "Total: " + totalValueLabel.text!
        
        print("Order Body: \(result)")
        return result
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) {
            self.placeOrder()
            Catalog.sharedCatalog.cart.products.removeAll()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func placeOrder() -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            Alamofire.request(.POST, AppConstants.XMLRemoteResourcePath, parameters: ["type": "postmessage", "user_id": "22", "email": self.emailTextField.text!, "phone": self.phoneTextField.text!, "address": "test", "notes": self.commentTextView.text!, "sender_name": self.nameTextField.text!, "order_total": self.totalValue, "order_summary": self.orderSummary])
//                .validate()
//                .responseData { response in
//                    switch response.result {
//                    case .Success:
//                        print("Success")
//                        DTIToastCenter.defaultCenter.makeText("Order placed successfully")
//                        let fileURL = self.selectedImageURL
//                        Alamofire.upload(.POST, AppConstants.XMLRemoteResourcePath, file: fileURL!)
//                        
//                    case .Failure(let error):
//                        print(error)
//                    }
//            }
            
            let userInfo = ["type": "postmessage", "user_id": AppConstants.userId, "email": self.emailTextField.text!, "phone": self.phoneTextField.text!, "address": "test", "notes": self.commentTextView.text!, "sender_name": self.nameTextField.text!, "order_total": "\(self.totalValue)"]
            
            Alamofire.upload(.POST, AppConstants.XMLRemoteResourcePath, multipartFormData: {
                multipartFormData in
                
                if let _image = self.selectImageButton.backgroundImageForState(.Normal) {
                    if let imageData = UIImageJPEGRepresentation(_image, 0.5) {
                        multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "file.png", mimeType: "image/png")
                    }
                }
                
                for (key, value) in userInfo {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
                
                let orderData = try! NSJSONSerialization.dataWithJSONObject(self.orderSummary, options: NSJSONWritingOptions.PrettyPrinted)
                multipartFormData.appendBodyPart(data: orderData, name: "order_summary")
                
                }, encodingCompletion: {
                    encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        print("s")
                        upload.responseData { response in
                            switch response.result {
                            case .Success:
//                                let xmlCatalog = SWXMLHash.parse(response.result.value!)["xml"]
//                                print(xmlCatalog)
//                                
//                                print(response.request)  // original URL request
//                                print(response.response) // URL response
//                                print(response.data)     // server data
//                                print(response.result)   // result of response serialization
                                
                                var order = "order sent"
                                
                                if let appSettings = NSUserDefaults.standardUserDefaults().dictionaryForKey("appSettings") {
                                    order = appSettings["ordersent"] as! String
                                }
                                
                                DTIToastCenter.defaultCenter.makeText(order)
                                
                            case .Failure(let error):
                                print(error)
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
            })
        }
    }
}

extension CheckoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        let configuredImageViewController = configuredImagePickerViewController()
        self.presentViewController(configuredImageViewController, animated: true, completion: nil)
    }
    
    func configuredImagePickerViewController() -> UIImagePickerController {
        imagePickerVC.delegate = self
        
        imagePickerVC.allowsEditing = false
        imagePickerVC.sourceType = .PhotoLibrary
        
        return imagePickerVC
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //selectImageButton.imageView?.contentMode = .ScaleAspectFit
            selectImageButton.setTitle("", forState: .Normal)
            selectImageButton.setBackgroundImage(pickedImage, forState: .Normal)
        }
        print(info)
        if let pickedImageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
            selectedImageURL = pickedImageURL
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
