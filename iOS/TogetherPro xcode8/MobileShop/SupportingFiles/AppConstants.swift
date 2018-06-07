//
//  AppSettings.swift
//  TogetherPro
//
//  Copyright © 2015 Syed. All rights reserved.
//

import UIKit
import SnappingStepper
import SWXMLHash
import Alamofire

struct AppConstants {
    /// Theme of the app. Replace the value with any of these:
    /// - .ThemeGreen
    /// - .ThemeBlue
    /// - .ThemeOrange
    /// - .ThemePurple
    /// - .ThemeDarkBlue
    /// - .ThemeNeutral
    /// - .ThemePink
    static let appTheme: AppTheme = .ThemeGreen
    
    ///The Constant currency.
    static let currency = "$"
    
    ///The Constant VAT.
    static let VAT = 0.2
    
    /// The Constant XMLResourcePath. Here you can either have some network xml resource or local file in assets folder.
    static let XMLResourcePath = "catalog"
    static let XMLRemoteResourcePath = "http://app.togetherpro.com/index.php/api/main"
//    static let XMLResourcePath = "http://Syed.com/apps/catalog/catalog_web_v2_2.xml"
    
    /// The Constant userId.
    static let userId = "22"
    
    /// The Constant catalogName.
    static let catalogName = "Mobile Store"
    
    /// The Constant mailAddress.
    static let mailAddress = "sales@domain.com";
    
    /// The Constant phoneNumber.
    static let phoneNumber = "555-555-33";
    
    /// The Constant skype.
    static let skype = "mobi.store";
    
    /// The Constant facebook.
    static let facebook = "facebook.com/mobistore";
    
    /// The Constant OneSignal AppId
    static let OneSignalAppId = "" // ENTER_YOUR_KEY
    
    /// The Constant orderIdDateFormat used for generating orderId on checkout: "currentDate-suffix"
    static let orderIdDateFormat = "YYYYMMdd"
    
    /// The Constant orderIdSuffixLength used for generating orderId on checkout: "currentDate-suffix"
    static let orderIdSuffixLength = 6
}

extension AppConstants {
    static func applyCurrentTheme() {
        let mainColor = appTheme.mainColor
        let darkerColor = appTheme.darkerColor
        
        UINavigationBar.appearance().barTintColor = mainColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        
        MainBackgroundColorView.appearance().backgroundColor = mainColor
        DarkerBackgroundColorView.appearance().backgroundColor = darkerColor
        
        MainBackgroundColorButton.appearance().backgroundColor = mainColor
        MainTextColorButton.appearance().setTitleColor(mainColor, forState: .Normal)
        MainTextColorButton.appearance().setTitleColor(mainColor, forState: .Highlighted)
        
        MainBackgroundColorLabel.appearance().backgroundColor = mainColor
        MainTextColorLabel.appearance().textColor = mainColor
        
        UIPageControl.appearance().currentPageIndicatorTintColor = mainColor
        
        Alamofire.request(.GET, XMLRemoteResourcePath, parameters: ["type": "getprofile", "user_id": userId])
            .validate()
            .responseData { response in
                switch response.result {
                case .Success:
                    let xmlCatalog = SWXMLHash.parse(response.result.value!)["xml"]
                    //print(xmlCatalog["username"].element?.text)
                    //catalogName = (xmlCatalog["username"].element?.text)!
                    NSUserDefaults.standardUserDefaults().setObject(xmlCatalog["ios_icon_url"].element?.text, forKey: "ios_icon_url")
                    NSUserDefaults.standardUserDefaults().setObject(xmlCatalog["username"].element?.text, forKey: "username")
                    NSUserDefaults.standardUserDefaults().setObject(xmlCatalog["email"].element?.text, forKey: "email")
                    NSUserDefaults.standardUserDefaults().setObject(xmlCatalog["telephone"].element?.text, forKey: "telephone")
                    NSUserDefaults.standardUserDefaults().setObject(xmlCatalog["fb_link"].element?.text, forKey: "fb_link")
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
}

enum AppTheme: String {
    case ThemeGreen     = "theme_green"
    case ThemeBlue      = "theme_blue"
    case ThemeOrange    = "theme_orange"
    case ThemePurple    = "theme_purple"
    case ThemeDarkBlue  = "theme_darkblue"
    case ThemeNeutral   = "theme_neutral"
    case ThemePink      = "theme_pink"
    
    var mainColor: UIColor {
        get {
            let mainColorKey = self.rawValue + "_main_color"
            return colorWithHexString(String(colorsDictionary[mainColorKey]!))
        }
    }
    
    var darkerColor: UIColor {
        get {
            let mainColorKey = self.rawValue + "_main_color_darker"
            return colorWithHexString(String(colorsDictionary[mainColorKey]!))
        }
    }
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

//MARK: Color utilities

var colorsDictionary: NSDictionary {
    get {
        return NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Colors", ofType: "plist")!)!
    }
}

func colorWithHexString(hex: String) -> UIColor
{
    let scanner = NSScanner(string: hex)
    scanner.charactersToBeSkipped = NSCharacterSet.alphanumericCharacterSet().invertedSet
    
    var value: UInt32 = 0;
    scanner.scanHexInt(&value)
    
    let red = CGFloat(Float(Int(value >> 16) & 0x000000FF)/255.0)
    let green = CGFloat(Float(Int(value >> 8) & 0x000000FF)/255.0)
    let blue = CGFloat(Float(Int(value) & 0x000000FF)/255.0)
    
    let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    return color
}

