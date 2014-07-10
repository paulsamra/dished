//
//  DASaveLocationTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASaveLocationTableViewController.h"
#import "DAFormTableViewController.h"

@interface DASaveLocationTableViewController ()

@end

@implementation DASaveLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameTextField becomeFirstResponder];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    separatorLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorLineView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)save:(id)sender {
    
    NSArray *navigationStack = self.navigationController.viewControllers;

    for (UIViewController *parentController in navigationStack) {
        if ([parentController isKindOfClass:[DAFormTableViewController class]]) {
            [(DAFormTableViewController *)parentController setDetailItem:self.nameTextField.text];
            [self.navigationController popToViewController:parentController animated:NO];
        }
    }
}
@end
