//
//  DAGetSocialView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAGetSocialView: DAView, UITableViewDataSource {

    var tableView: UITableView!
    var skipButton: UIButton!
    let rowHeight = 44.0
    
    let cellTitles = [
        "Find Friends from Contacts",
        "Active Foodies in your Area"
    ]
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = cellTitles[indexPath.row]
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell!.textLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 18.0)
        
        return cell!
    }
    
    override func setupViews() {
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.dataSource = self
        let headerImage = UIImage(named: "get_social")
        tableView.tableHeaderView = tableHeaderView(headerImage!)
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    private func tableHeaderView(image: UIImage) -> UIView {
        let backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        let imageSize = image.size
        backgroundImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
        
        let label = UILabel()
        label.text = "The more friends you have joining on this\nculinary journey, the better your\nrecommendations will be."
        label.textColor = UIColor.whiteColor()
        label.alpha = 0.7
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 3
        label.sizeToFit()
        backgroundImageView.addSubview(label)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Right)
        label.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        label.autoSetDimension(ALDimension.Height, toSize: label.frame.size.height)
        
        return backgroundImageView
    }
    
//    private func tableFooterView() -> UIView {
//        let footerView = UIView()
//        
//    }
}