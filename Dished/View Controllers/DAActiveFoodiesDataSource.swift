//
//  File.swift
//  Dished
//
//  Created by Ryan Khalili on 3/30/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAActiveFoodiesDataSource: DADataSource {
    
    var data: [AnyObject] {
        get {
            return self.foodies
        }
    }
    
    private var foodies = [DAFoodie]()
    weak var delegate: DADataSourceDelegate?
    private var foodiesRequest: NSURLSessionTask?
    
    init() {
        
    }
    
    func loadData() {
        foodiesRequest = DAAPIManager.sharedManager().GETRequest(kUsersFindURL, withParameters: nil, success: {
            response in
            
            if let users = response.objectForKey(kDataKey) as? [NSDictionary] {
                var foodies = [DAFoodie]()
                
                for user in users {
                    let foodie = DAFoodie()
                    
                    if let userReviews = user[kReviewsKey] as? NSArray {
                        if userReviews.count == 0 {
                            continue
                        }
                        
                        var reviews = [String]()
                        
                        for review in userReviews {
                            if let image = review[kImgThumbKey] as? String {
                                reviews.append(image)
                            }
                        }
                        
                        foodie.reviews = reviews
                    }
                    
                    foodie.username = user[kUsernameKey] as? String ?? ""
                    foodie.description = user[kDescriptionKey] as? String ?? ""
                    foodie.userID = ( user[kIDKey] as? String ?? "" ).toInt() ?? 0
                    foodie.image = user[kImgThumbKey] as? String ?? ""
                    
                    let firstName = user[kFirstNameKey] as? String ?? ""
                    let lastName = user[kLastNameKey] as? String ?? ""
                    foodie.name = "\(firstName) \(lastName)"
                    
                    foodie.type = user[kTypeKey] as? String ?? ""
                    
                    foodies.append(foodie)
                }
                
                self.foodies = foodies
            }
            
            self.delegate?.dataSourceDidFinishLoadingData(self)
            return
        },
        failure: {
            error, shouldRetry in
            
            if shouldRetry {
                self.loadData()
                return
            }
            
            self.delegate?.dataSourceDidFailToLoadData(self, withError: error)
        })
    }
    
    func cancelLoadingData() {
        foodiesRequest?.cancel()
    }
}