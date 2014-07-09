//
//  AutoComleteTableView.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AutoComleteTableView.h"
#import "DAFormTableViewController.h"


@implementation AutoComleteTableView
@synthesize pastUrls;
@synthesize autocompleteUrls;


DAFormTableViewController *caller;



- (id)initWithFrame:(CGRect)frame withClass:(id) class
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        // Initialization code
        caller = class;
        self.pastUrls = [[NSMutableArray alloc] initWithObjects:@"YooGood Cream", @"Yoaghetti", @"Yogart", nil];
        self.autocompleteUrls = [[NSMutableArray alloc] init];
        self.delegate = self;
        self.dataSource	= self;

        
        
    }
    return self;
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    [autocompleteUrls removeAllObjects];
    for(NSString *curString in pastUrls) {
        NSRange substringRange = [curString.lowercaseString rangeOfString:substring.lowercaseString];
        if (substringRange.location == 0) {
            [autocompleteUrls addObject:curString];
        }
    }
    [self reloadData];
}



#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    UIImageView *iconPlaceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_dish_location.png"]];
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(225, 44/2 - 7.5, 80, 30/2)];
    location.text = @"Skopje City Mall";
    location.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    location.textColor = [UIColor lightGrayColor];
    [backgroundView addSubview:iconPlaceImage];
    [backgroundView addSubview:location];
    iconPlaceImage.frame = CGRectMake(210, 44/2 - 7.5, 21/2, 30/2);
    cell.backgroundView = backgroundView;
    cell.textLabel.text = [autocompleteUrls objectAtIndex:indexPath.row];
    return cell;
    
    
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@", selectedCell.textLabel.text);
    caller.titleTextView.text = selectedCell.textLabel.text;
    self.hidden = YES;
    
    
}




@end
