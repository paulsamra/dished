//
//  DADataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 3/27/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

protocol DADataSource {
    var data: [AnyObject] { get }
    weak var delegate: DADataSourceDelegate? { get set }
    
    func loadData()
    func cancelLoadingData()
}