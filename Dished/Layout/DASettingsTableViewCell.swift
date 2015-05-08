//
//  DASettingsTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

enum DASettingsTableViewCellStyle {
    case Plain
    case Destructive
    case Switch
}

protocol DASettingsTableViewCellDelegate: class {
    func settingsTableViewCell(cell: DASettingsTableViewCell, didSetSwitchOn on: Bool)
}

class DASettingsTableViewCell: DATableViewCell {
    
    var selectorSwitch: UISwitch!
    
    weak var delegate: DASettingsTableViewCellDelegate?
    
    var style: DASettingsTableViewCellStyle = DASettingsTableViewCellStyle.Plain {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        selectionStyle = UITableViewCellSelectionStyle.Default
        accessoryType = UITableViewCellAccessoryType.None
        selectorSwitch.hidden = true
        textLabel?.textColor = UIColor.blackColor()
        
        if style == DASettingsTableViewCellStyle.Switch {
            selectionStyle = UITableViewCellSelectionStyle.None
            selectorSwitch.hidden = false
        }
        else if style == DASettingsTableViewCellStyle.Plain {
            accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else if style == DASettingsTableViewCellStyle.Destructive {
            textLabel?.textColor = UIColor.redColor()
        }
    }
    
    override func prepareForReuse() {
        textLabel?.text = ""
        selectorSwitch.hidden = true
        selectionStyle = UITableViewCellSelectionStyle.Default
        accessoryType = UITableViewCellAccessoryType.None
        textLabel?.textColor = UIColor.blackColor()
    }
    
    func switchToggled() {
        delegate?.settingsTableViewCell(self, didSetSwitchOn: selectorSwitch.on)
    }
    
    override func setupViews() {
        textLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        selectorSwitch = UISwitch()
        selectorSwitch.sizeToFit()
        selectorSwitch.addTarget(self, action: "switchToggled", forControlEvents: UIControlEvents.ValueChanged)
        addSubview(selectorSwitch)
        selectorSwitch.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        selectorSwitch.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 15.0)
        selectorSwitch.autoSetDimensionsToSize(selectorSwitch.bounds.size)
    }
}