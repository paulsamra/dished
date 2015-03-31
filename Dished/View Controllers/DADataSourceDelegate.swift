//
//  DADataSourceDelegate.swift
//  Dished
//
//  Created by Ryan Khalili on 3/30/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

protocol DADataSourceDelegate: class {
    func dataSourceDidFinishLoadingData(dataSource: DADataSource)
    func dataSourceDidFailToLoadData(dataSource: DADataSource, withError error: NSError?)
}