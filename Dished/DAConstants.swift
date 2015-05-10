//
//  DAConstants.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

@objc enum DADishType: Int {
    case Food, Cocktail, Wine
    
    var name: String {
        get {
            switch(self) {
                case .Food: return kFood
                case .Cocktail: return kCocktail
                case .Wine: return kWine
            }
        }
    }
}

struct DAConstants
{
    static func launchImage() -> UIImage? {
        let is4 = UIScreen.mainScreen().bounds.size.height - 480 == 0
        let is5 = UIScreen.mainScreen().bounds.size.height - 568 == 0
        let is6 = UIScreen.mainScreen().bounds.size.height - 667 == 0
        let is6Plus = UIScreen.mainScreen().bounds.size.height - 736 == 0
        
        if is4 {
            return UIImage(named: "LaunchImage-700@2x.png")
        }
        else if is5 {
            return UIImage(named: "LaunchImage-700-568h@2x.png")
        }
        else if is6 {
            return UIImage(named: "LaunchImage-800-667h@2x.png")
        }
        else if is6Plus {
            return UIImage(named: "LaunchImage-800-Portrait-736h@3x")
        }
            
        return nil
    }
    
    static func primaryFontWithSize( size: CGFloat ) -> UIFont
    {
        return UIFont( name: kHelveticaNeueLightFont, size: size )!
    }
}