//
//  DAFoodie.swift
//  Dished
//
//  Created by Ryan Khalili on 3/28/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAFoodie {
    
    var username: String = ""
    var description: String = ""
    var image: String = ""
    var userID: Int = 0
    var name: String = ""
    var userType: String = ""
    var following: Bool = false
    var reviews: [(reviewID: Int, image: String)] = []
}