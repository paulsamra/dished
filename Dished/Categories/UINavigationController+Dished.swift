//
//  UINavigationController+Dished.swift
//  Dished
//
//  Created by Ryan Khalili on 5/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    func showOverlayWithTitle(title: String) {
        MRProgressOverlayView.showOverlayAddedTo(view, title: title, mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
    }
    
    func hideOverlayWithCompletion(completion: (() -> ())?) {
        MRProgressOverlayView.dismissOverlayForView(view, animated: true, completion: {
            completion?()
        })
    }
}