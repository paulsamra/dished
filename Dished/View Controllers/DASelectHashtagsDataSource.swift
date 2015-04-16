//
//  DASelectHashtagsDataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 4/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

@objc enum DASelectHashtagsType: Int {
    case Positive, Negative
    
    var name: String {
        get {
            switch(self) {
            case .Positive: return kPositiveHashtags
            case .Negative: return kNegativeHashtags
            }
        }
    }
}

class DASelectHashtagsDataSource: NSObject, DADataSource {
    
    var hashtagsType = DASelectHashtagsType.Positive
    var loadHashtagsTask: NSURLSessionTask?
    var dishType = DADishType.Food
    
    var hashtags: [DAHashtag] {
        get {
            var hashtags: [DAHashtag]
            
            switch(hashtagsType) {
            case .Positive: hashtags = positiveUserHashtags + (positiveHashtags ?? [])
            case .Negative: hashtags = negativeUserHashtags + (negativeHashtags ?? [])
            }
            
            return hashtags
        }
    }
    
    weak var delegate: DADataSourceDelegate? = nil
    
    private var positiveHashtags: [DAHashtag]?
    private var negativeHashtags: [DAHashtag]?
    
    private var positiveUserHashtags = [DAHashtag]()
    private var negativeUserHashtags = [DAHashtag]()
    
    var selectedHashtags: [DAHashtag] {
        get {
            return chosenHashtags.values.array + chosenUserHashtags.values.array
        }
    }
    
    private var chosenHashtags = [Int:DAHashtag]()
    private var chosenUserHashtags = [String:DAHashtag]()
    
    override init() {
        super.init()
    }
    
    init(hashtagsType: DASelectHashtagsType, dishType: DADishType) {
        self.hashtagsType = hashtagsType
        self.dishType = dishType
        
        super.init()
    }
    
    func hashtagIsSelected(hashtag: DAHashtag) -> Bool {
        if hashtag.userDefined {
            return chosenUserHashtags[hashtag.name] != nil
        }
        
        return chosenHashtags[hashtag.hashtag_id] != nil
    }
    
    func selectHashtag(hashtag: DAHashtag) {
        if hashtag.userDefined {
            chosenUserHashtags[hashtag.name] = hashtag
        }
        else {
            chosenHashtags[hashtag.hashtag_id] = hashtag
        }
    }
    
    func deselectHashtag(hashtag: DAHashtag) {
        if hashtag.userDefined {
            chosenUserHashtags[hashtag.name] = nil
        }
        else {
            chosenHashtags[hashtag.hashtag_id] = nil
        }
    }
    
    func addUserDefinedHashtagWithName(name: String) -> DAHashtag {
        let hashtag = DAHashtag()
        hashtag.name = name
        hashtag.userDefined = true
        
        switch(hashtagsType) {
        case .Positive: positiveUserHashtags.insert(hashtag, atIndex: 0)
        case .Negative: negativeUserHashtags.insert(hashtag, atIndex: 0)
        }
        
        return hashtag
    }
    
    func loadData() {
        let parameters = [
            kDishTypeKey: dishType.name,
            kHashtagTypeKey: hashtagsType.name
        ]
        
        loadHashtagsTask = DAAPIManager.sharedManager().GETRequest(kHashtagsURL, withParameters: parameters, success: {
            response in
            
            let hashtags = self.hashtagsFromResponse(response[kDataKey] as! [NSDictionary])
            
            if self.hashtagsType == DASelectHashtagsType.Positive {
                self.positiveHashtags = hashtags
            }
            else {
                self.negativeHashtags = hashtags
            }
            
            self.delegate?.dataSourceDidFinishLoadingData(self)
        },
        failure: {
            error, retry in
            
            if retry {
                self.loadData()
            }
            else {
                self.delegate?.dataSourceDidFailToLoadData(self, withError: error)
            }
        })
    }
    
    private func hashtagsFromResponse(response: [NSDictionary]) -> [DAHashtag] {
        var hashtags = [DAHashtag]()
        
        for data in response {
            let hashtag = DAHashtag()
            hashtag.name = data[kNameKey] as? String ?? ""
            hashtag.hashtag_id = ( data[kIDKey] as? String ?? "" ).toInt() ?? 0
            
            hashtags.append(hashtag)
        }
        
        return hashtags
    }
    
    func cancelLoadingData() {
        loadHashtagsTask?.cancel()
    }
}