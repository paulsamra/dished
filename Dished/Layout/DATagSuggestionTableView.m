//
//  DATagSuggestionTableView.m
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DATagSuggestionTableView.h"
#import "DATagManager.h"


@interface DATagSuggestionTableView()

@property (copy,   nonatomic) NSString *prefix;
@property (strong, nonatomic) NSArray *suggestions;

@end


@implementation DATagSuggestionTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        _suggestions    = [NSArray array];
        self.delegate   = self;
        self.dataSource	= self;
        _prefix = @"#";
        
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        self.rowHeight = 44.0;
    }
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *text = [self.suggestions objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", self.prefix, text];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( [self.prefix isEqualToString:@"@"] )
    {
        if( [self.suggestionDelegate respondsToSelector:@selector(didSelectUsernameWithName:)] )
        {
            [self.suggestionDelegate didSelectUsernameWithName:[self.suggestions objectAtIndex:indexPath.row]];
        }
    }
    else if( [self.prefix isEqualToString:@"#"] )
    {
        if( [self.suggestionDelegate respondsToSelector:@selector(didSelectHashtagWithName:)] )
        {
            [self.suggestionDelegate didSelectHashtagWithName:[self.suggestions objectAtIndex:indexPath.row]];
        }
    }
}

- (void)updateUsernameSuggestionsWithQuery:(NSString *)query
{
    self.prefix = @"@";
    self.suggestions = [DATagManager usernamesForQuery:query];
    [self reloadData];
}

- (void)updateHashtagSuggestionsWithQuery:(NSString *)query
{
    self.prefix = @"#";
    self.suggestions = [DATagManager hashtagsForQuery:query];
    [self reloadData];
}

- (void)resetTable
{
    self.suggestions = @[ ];
    [self reloadData];
}

@end