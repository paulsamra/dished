//
//  DAPositiveHashtagsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAPositiveHashtagsViewController.h"
#import "DANegativeHashtagsViewController.h"
#import "DAAPIManager.h"
#import "DAHashtag.h"


@interface DAPositiveHashtagsViewController()

@property (strong, nonatomic) NSArray                 *hashtagArray;
@property (strong, nonatomic) NSMutableDictionary     *selectedHashtags;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL errorLoading;

@end


@implementation DAPositiveHashtagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hashtagArray = [NSArray array];
    self.selectedHashtags = [NSMutableDictionary dictionary];
    self.errorLoading = NO;
    
    [[DAAPIManager sharedManager] getPositiveHashtagsForDishType:self.dishType
    completion:^( NSArray *hashtags, NSError *error )
    {
        if( error || !hashtags )
        {
            self.errorLoading = YES;
        }
        else
        {
            self.hashtagArray = hashtags;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( [self.hashtagArray count] == 0 )
    {
        return 1;
    }
    else
    {
        return [self.hashtagArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hashtagCell"];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hashtagCell"];
    }
    
    if( [self.hashtagArray count] == 0 )
    {
        cell.textLabel.text = @"Loading...";

        cell.accessoryView = self.spinner;
        [self.spinner startAnimating];
    }
    else
    {
        [self.spinner removeFromSuperview];
        [self.spinner stopAnimating];
        
        DAHashtag *hashtag = [self.hashtagArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
        
        UIImageView *imageView = nil;
        
        if( [self.selectedHashtags[@(indexPath.row)] boolValue] )
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_dish_hashtag_checked"]];
        }
        else
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_dish_hashtag_unchecked"]];
        }
        
        cell.accessoryView = imageView;
        imageView.tag = 100;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL selected = ![[self.selectedHashtags objectForKey:@(indexPath.row)] boolValue];
    
    [self.selectedHashtags setObject:@(selected) forKey:@(indexPath.row)];
    
    UIView *accessoryView = [[tableView cellForRowAtIndexPath:indexPath] accessoryView];
    
    if( accessoryView.tag == 100 )
    {
        UIImageView *imageView = (UIImageView *)accessoryView;
        
        if( selected )
        {
            imageView.image = [UIImage imageNamed:@"add_dish_hashtag_checked"];
        }
        else
        {
            imageView.image = [UIImage imageNamed:@"add_dish_hashtag_unchecked"];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake( 0, 0, self.tableView.frame.size.width, 50 );
    
    UIView *header = [[UIView alloc] initWithFrame:frame];
    header.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"What do you like about the dish?";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (IBAction)goToNegHashtags:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"negHashtags" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"negHashtags"] )
    {
        DANegativeHashtagsViewController *dest = segue.destinationViewController;
        dest.dishType = self.dishType;
    }
}

- (UIActivityIndicatorView *)spinner
{
    if( !_spinner )
    {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

@end
