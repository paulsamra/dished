//
//  DAHashtagInputTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 4/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DAHashtagInputTableViewCellDelegate: class {
    func hashtagInputTableViewCell(cell: DAHashtagInputTableViewCell, didAddHashtagWithName name: String)
}

class DAHashtagInputTableViewCell: DATableViewCell {
    
    var textField: UITextField!
    var addButton: UIButton!
    
    weak var delegate: DAHashtagInputTableViewCellDelegate?
    
    override func setupViews() {
        addButton = UIButton()
        addButton.setTitle("Add", forState: UIControlState.Normal)
        addButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        addButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        addButton.titleLabel?.font = DAConstants.primaryFontWithSize(18.0)
        addButton.addTarget(self, action: "addButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.sizeToFit()
        contentView.addSubview(addButton)
        addButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 10.0)
        addButton.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        addButton.autoSetDimensionsToSize(addButton.frame.size)
        
        textField = UITextField()
        textField.font = DAConstants.primaryFontWithSize(18.0)
        textField.placeholder = "Create your own"
        textField.keyboardType = UIKeyboardType.ASCIICapable
        textField.addTarget(self, action: "textFieldChanged", forControlEvents: UIControlEvents.EditingChanged)
        textField.addTarget(self, action: "textFieldBeganEditing", forControlEvents: UIControlEvents.EditingDidBegin)
        textField.addTarget(self, action: "textFieldEndedEditing", forControlEvents: UIControlEvents.EditingDidEnd)
        textField.returnKeyType = UIReturnKeyType.Done
        contentView.addSubview(textField)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 15.0)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        textField.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: addButton, withOffset: -15.0)
        
        addButton.enabled = !textField.text.isEmpty
    }
    
    func textFieldChanged() {
        addButton.enabled = !textField.text.isEmpty && textField.text != "#"
        
        let text = textField.text
        
        if !text.isEmpty && text != "#" {
            let characterSet = NSCharacterSet.alphanumericCharacterSet()
            let lastEntered = text.substringFromIndex(advance(text.startIndex, count(text) - 1))
            
            if lastEntered.rangeOfCharacterFromSet(characterSet, options: nil, range: nil) == nil {
                textField.text = text.substringToIndex(advance(text.startIndex, count(text) - 1))
            }
        }
        
        if text.isEmpty {
            textField.text = "#"
        }
    }
    
    func textFieldBeganEditing() {
        if textField.text.isEmpty {
            textField.text = "#"
        }
        
        addButton.enabled = !textField.text.isEmpty && textField.text != "#"
    }
    
    func textFieldEndedEditing() {
        if textField.text == "#" {
            textField.text = ""
        }
        
        addButton.enabled = !textField.text.isEmpty && textField.text != "#"
    }
    
    func addButtonPressed() {
        let name = textField.text.substringFromIndex(advance(textField.text.startIndex, 1))
        delegate?.hashtagInputTableViewCell(self, didAddHashtagWithName: name)
        textField.text = ""
    }
}