//
//  DAExploreDefinedSearchViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDefinedSearchViewController.h"
#import "DAAPIManager.h"


@interface DAExploreDefinedSearchViewController()

@property (strong, nonatomic) NSArray                 *searchResults;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAExploreDefinedSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults = [NSArray array];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end