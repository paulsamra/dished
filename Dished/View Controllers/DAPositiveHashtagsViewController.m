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
@property (strong, nonatomic) NSMutableArray          *selectedHashtags;
@property (strong, nonatomic) NSMutableDictionary     *hashtagDict;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAPositiveHashtagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hashtagArray = [NSArray array];
    self.hashtagDict = [NSMutableDictionary dictionary];
    
    [self loadHashtags];
}

- (void)loadHashtags
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSDictionary *parameters = @{ kDishTypeKey : self.review.type, kHashtagTypeKey : kPositiveHashtags };
    
    __weak typeof( self ) weakSelf = self;
    
    [self addURLTaskWithURL:kHashtagsURL parameters:parameters
    successBlock:^( NSURLSessionDataTask *task, id responseObject )
    {
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        weakSelf.hashtagArray = [weakSelf hashtagsFromResponse:responseObject];
        weakSelf.selectedHashtags = [weakSelf.review.hashtags mutableCopy];
        
        if( !weakSelf.selectedHashtags )
        {
            weakSelf.selectedHashtags = [NSMutableArray array];
        }
        
        for( DAHashtag *tag in weakSelf.selectedHashtags )
        {
            NSUInteger index = [weakSelf.hashtagArray indexOfObject:tag];
            
            if( index != NSNotFound )
            {
                [weakSelf.hashtagDict setObject:@"selected" forKey:@(index)];
            }
        }
        
        for( id key in weakSelf.hashtagDict )
        {
            [weakSelf.selectedHashtags removeObject:[weakSelf.hashtagArray objectAtIndex:[key intValue]]];
        }
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    }
    failureBlock:^( NSURLSessionDataTask *task, NSError *error )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( errorType != eErrorTypeRequestCancelled )
        {
            
        }
    }];
}

- (NSArray *)hashtagsFromResponse:(id)response
{
    NSArray *hashtags = nilOrJSONObjectForKey( response, kDataKey );
    NSMutableArray *newHashtags = [NSMutableArray array];

    if( hashtags )
    {
        for( NSDictionary *hashtag in hashtags )
        {
            DAHashtag *newHashtag = [DAHashtag hashtagWithData:hashtag];
            [newHashtags addObject:newHashtag];
        }
    }
    
    return newHashtags;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hashtagArray.count == 0 ? 1 : self.hashtagArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hashtagCell"];
    
    if( [self.hashtagArray count] == 0 )
    {
        cell.textLabel.text = @"Loading...";

        cell.accessoryView = self.spinner;
        cell.userInteractionEnabled = NO;
        [self.spinner startAnimating];
    }
    else
    {
        [self.spinner removeFromSuperview];
        [self.spinner stopAnimating];
        
        DAHashtag *hashtag = [self.hashtagArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
        
        UIImageView *imageView = nil;
        
        if( [self.hashtagDict objectForKey:@(indexPath.row)] )
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hashtag_checked"]];
        }
        else
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hashtag_unchecked"]];
        }
        
        cell.accessoryView = imageView;
        imageView.tag = 100;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL selected = ![self.hashtagDict objectForKey:@(indexPath.row)];
    
    if( selected )
    {
        [self.hashtagDict setObject:@"selected" forKey:@(indexPath.row)];
    }
    else
    {
        [self.hashtagDict removeObjectForKey:@(indexPath.row)];
    }
    
    UIView *accessoryView = [[tableView cellForRowAtIndexPath:indexPath] accessoryView];
    
    if( accessoryView.tag == 100 )
    {
        UIImageView *imageView = (UIImageView *)accessoryView;
        
        if( selected )
        {
            imageView.image = [UIImage imageNamed:@"hashtag_checked"];
        }
        else
        {
            imageView.image = [UIImage imageNamed:@"hashtag_unchecked"];
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
    for( id key in self.hashtagDict )
    {
        [self.selectedHashtags addObject:[self.hashtagArray objectAtIndex:[key intValue]]];
    }
    
    [self performSegueWithIdentifier:@"negHashtags" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"negHashtags"] )
    {
        DANegativeHashtagsViewController *dest = segue.destinationViewController;
        dest.review = self.review;
        dest.selectedHashtags = self.selectedHashtags;
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
