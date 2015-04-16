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
    
    var hashtagsType = DASelectHashtagsType.Positive {
        didSet {
            switch(hashtagsType) {
            case .Positive: self.hashtags = self.positiveHashtags ?? [DAHashtag]()
            case .Negative: self.hashtags = self.negativeHashtags ?? [DAHashtag]()
            }
        }
    }
    
    var loadHashtagsTask: NSURLSessionTask?
    var dishType = DADishType.Food
    var hashtags = [DAHashtag]()
    weak var delegate: DADataSourceDelegate? = nil
    
    private var positiveHashtags: [DAHashtag]?
    private var negativeHashtags: [DAHashtag]?
    
    var selectedHashtags: [DAHashtag] {
        get {
            return chosenHashtags.values.array
        }
    }
    
    private var chosenHashtags = [Int:DAHashtag]()
    
    override init() {
        super.init()
    }
    
    init(hashtagsType: DASelectHashtagsType, dishType: DADishType) {
        self.hashtagsType = hashtagsType
        self.dishType = dishType
        
        super.init()
    }
    
    func hashtagIsSelected(hashtag: DAHashtag) -> Bool {
        return chosenHashtags[hashtag.hashtag_id] != nil
    }
    
    func selectHashtag(hashtag: DAHashtag) {
        chosenHashtags[hashtag.hashtag_id] = hashtag
    }
    
    func deselectHashtag(hashtag: DAHashtag) {
        chosenHashtags[hashtag.hashtag_id] = nil
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
                self.hashtags = self.positiveHashtags!
            }
            else {
                self.negativeHashtags = hashtags
                self.hashtags = self.negativeHashtags!
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