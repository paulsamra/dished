//
//  AutoComleteTableView.h
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DADishNamesTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *pastUrls;
    NSMutableArray *autocompleteUrls;
}

@property (nonatomic, retain) NSMutableArray *pastUrls;
@property (nonatomic, retain) NSMutableArray *autocompleteUrls;


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (id)initWithFrame:(CGRect)frame withClass:(id) class;

@end