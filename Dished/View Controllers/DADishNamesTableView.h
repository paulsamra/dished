//
//  AutoComleteTableView.h
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DADishNamesTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *pastUrls;
@property (strong, nonatomic) NSMutableArray *autocompleteUrls;


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (id)initWithFrame:(CGRect)frame withClass:(id)class;

@end