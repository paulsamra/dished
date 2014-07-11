//
//  DAAddPlaceViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAddPlaceViewController.h"
#import "DAFormTableViewController.h"

@interface DAAddPlaceViewController ()

@end

@implementation DAAddPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.nameTextField becomeFirstResponder];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 0.5)];
    separatorLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorLineView];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (IBAction)save:(id)sender
{
    NSArray *navigationStack = self.navigationController.viewControllers;

    for( UIViewController *parentController in navigationStack )
    {
        if( [parentController isKindOfClass:[DAFormTableViewController class]] )
        {
            [(DAFormTableViewController *)parentController setDetailItem:self.nameTextField.text];
            [self.navigationController popToViewController:parentController animated:YES];
        }
    }
}
@end
