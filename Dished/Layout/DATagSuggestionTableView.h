//
//  DATagSuggestionTableView.h
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DATagSuggestionTableView;

@protocol DATagSuggestionsTableViewDelegate <NSObject>

@optional
- (void)didSelectUsernameWithName:(NSString *)name;
- (void)didSelectHashtagWithName:(NSString *)name;

@end


@interface DATagSuggestionTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<DATagSuggestionsTableViewDelegate> suggestionDelegate;

- (void)updateUsernameSuggestionsWithQuery:(NSString *)query;
- (void)updateHashtagSuggestionsWithQuery:(NSString *)query;
- (void)resetTable;

@end