//
//  File.swift
//  Dished
//
//  Created by Ryan Khalili on 3/30/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAActiveFoodiesDataSource: DADataSource {
    
    var users = [DAFoodie]()
    var foodies = [DAFoodie]()
    weak var delegate: DADataSourceDelegate?
    private var foodiesRequest: NSURLSessionTask?
    private var usersRequest: NSURLSessionTask?
    
    
    init() {
        
    }
    
    func loadData() {
        foodiesRequest = DAAPIManager.sharedManager().GETRequest(kUsersFindURL, withParameters: nil, success: {
            response in
            self.foodies = self.foodiesFromResponse(response, excludeEmptyReviews: true)
            self.delegate?.dataSourceDidFinishLoadingData(self)
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
    
    func loadUsersWithQuery(query: String, completion: () -> () ) {
        usersRequest?.cancel()
        
        if query.isEmpty {
            users = [DAFoodie]()
            completion()
            return
        }
        
        let parameters = ["search": query]
        
        usersRequest = DAAPIManager.sharedManager().GETRequest(kUsersFindURL, withParameters: parameters, success: {
            response in
            self.users = self.foodiesFromResponse(response, excludeEmptyReviews: false)
            completion()
        },
        failure: {
            error, shouldRetry in
                
            if shouldRetry {
                self.loadUsersWithQuery(query, completion: completion)
                return
            }
            
            self.users = [DAFoodie]()
            completion()
        })
    }
    
    private func foodiesFromResponse(response: AnyObject, excludeEmptyReviews: Bool) -> [DAFoodie] {
        var foodies = [DAFoodie]()
        
        if let users = response.objectForKey(kDataKey) as? [NSDictionary] {
            for user in users {
                let foodie = self.processFoodieData(user)
                
                if excludeEmptyReviews && foodie.reviews.count == 0 {
                    continue
                }
                
                foodies.append(foodie)
            }
        }
        
        return foodies
    }
    
    func resetUsersData() {
        users = [DAFoodie]()
        usersRequest?.cancel()
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
        
        foodie.userType = data[kTypeKey] as? String ?? ""
        
        return foodie
    }
    
    func cancelLoadingData() {
        foodiesRequest?.cancel()
        usersRequest?.cancel()
    }
}