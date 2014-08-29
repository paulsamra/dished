//
//  DACommentTableViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 8/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"


@interface DACommentTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end