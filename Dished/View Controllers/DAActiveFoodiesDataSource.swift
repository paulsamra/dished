//
//  File.swift
//  Dished
//
//  Created by Ryan Khalili on 3/30/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAActiveFoodiesDataSource: DADataSource {
    
    var foodies = [DAFoodie]()
    weak var delegate: DADataSourceDelegate?
    private var foodiesRequest: NSURLSessionTask?
    
    init(delegate: DADataSourceDelegate?) {
        self.delegate = delegate
    }
    
    func loadData() {
        foodiesRequest = DAAPIManager.sharedManager().GETRequest(kUsersFindURL, withParameters: nil, success: {
            response in
            
            if let users = response.objectForKey(kDataKey) as? [NSDictionary] {
                var foodies = [DAFoodie]()
                
                for user in users {
                    let foodie = self.processFoodieData(user)
                    
                    if foodie.reviews.count == 0 {
                        continue
                    }
                    
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
    
    private func processFoodieData(data: NSDictionary) -> DAFoodie {
        let foodie = DAFoodie()
        
        if let userReviews = data[kReviewsKey] as? NSArray {
            var reviews: [(reviewID: Int, image: String)] = []
            
            for review in userReviews {
                let reviewID = ( review[kIDKey] as? String ?? "" ).toInt() ?? 0
                let image = review[kImgThumbKey] as? String ?? ""
                reviews.append(reviewID: reviewID, image: image)
            }
            
            foodie.reviews = reviews
        }
        
        foodie.username = data[kUsernameKey] as? String ?? ""
        foodie.description = data[kDescriptionKey] as? String ?? ""
        foodie.userID = ( data[kIDKey] as? String ?? "" ).toInt() ?? 0
        foodie.image = data[kImgThumbKey] as? String ?? ""
        
        let firstName = data[kFirstNameKey] as? String ?? ""
        let lastName = data[kLastNameKey] as? String ?? ""
        foodie.name = "\(firstName) \(lastName)"
        
        foodie.type = data[kTypeKey] as? String ?? ""
        
        return foodie
    }
    
    func cancelLoadingData() {
        foodiesRequest?.cancel()
    }
}