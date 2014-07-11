//
//  SaveLocationTableViewController.h
//  Dished
//
//  Created by POST on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAddPlaceViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

- (IBAction)save:(id)sender;

@end