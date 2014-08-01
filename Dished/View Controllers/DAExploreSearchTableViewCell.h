//
//  DAExploreSearchCellTableViewCell.h
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAExploreSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel     *dishName;
@property (weak, nonatomic) IBOutlet UILabel     *locationName;
@property (weak, nonatomic) IBOutlet UILabel     *grade;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@end