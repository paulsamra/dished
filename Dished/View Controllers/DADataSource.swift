//
//  DADataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 3/27/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

protocol DADataSource {
    func loadData()
    func cancelLoadingData()
}