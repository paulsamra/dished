//
//  DAViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAViewController: UIViewController {
    
    var dismissesKeyboardOnTouch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackNavigationItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let keyboardRespondableView = view as? DAKeyboardRespondableView {
            keyboardRespondableView.beginObservingKeyboard()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardRespondableView = view as? DAKeyboardRespondableView {
            keyboardRespondableView.endObservingKeyboard()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if dismissesKeyboardOnTouch {
            view.endEditing(true)
        }
    }
    
    private func setupBackNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem( title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil )
    }
}