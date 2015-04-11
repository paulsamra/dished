//
//  DAFriend.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFriend: NSObject {
    
    var name: String = ""
    var username: String = ""
    var userID: Int = 0
    var registered: Bool = false
    var invited: Bool = false
    var following: Bool = false
    var image: String = ""
    var phoneNumber: String = ""
    
    func formattedPhoneNumber() -> String {
        if count(phoneNumber) != 10 {
            return phoneNumber
        }
        
        let areaCode = phoneNumber[0...2]!
        let firstThree = phoneNumber[3...5]!
        let lastFour = phoneNumber[6...9]!
        
        return "(\(areaCode)) \(firstThree)-\(lastFour)"
    }
    
    func formattedUsername() -> String {
        return "@\(username)"
    }
}