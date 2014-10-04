//
//  AutoComleteTableView.h
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DADishSuggestionsTableView;

@protocol DADishSuggestionsTableDelegate <NSObject>

- (void)selectedSuggestionWithDishName:(NSString *)dishName dishID:(NSInteger)dishID dishPrice:(NSString *)dishPrice locationName:(NSString *)locationName locationID:(NSInteger)locationID;

@end


@interface DADishSuggestionsTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<DADishSuggestionsTableDelegate> suggestionDelegate;

- (void)updateSuggestionsWithQuery:(NSString *)query dishType:(NSString *)dishType;
- (void)cancelSearchQuery;
- (void)resetTable;

@end