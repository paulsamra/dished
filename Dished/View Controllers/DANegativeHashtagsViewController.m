//
//  DAPositiveHashtagsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANegativeHashtagsViewController.h"
#import "DAAPIManager.h"
#import "DAHashtag.h"
#import "DAReviewFormViewController.h"


@interface DANegativeHashtagsViewController()

@property (strong, nonatomic) NSArray                 *hashtagArray;
@property (strong, nonatomic) NSMutableDictionary     *hashtagDict;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DANegativeHashtagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hashtagArray = [NSArray array];
    self.hashtagDict = [NSMutableDictionary dictionary];
    
    [self loadHashtags];
}

- (void)loadHashtags
{
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kDishTypeKey : self.review.type, kHashtagTypeKey : kNegativeHashtags };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [[DAAPIManager sharedManager] GET:kHashtagsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            self.hashtagArray = [self hashtagsFromResponse:responseObject];
            
            for( DAHashtag *tag in self.selectedHashtags )
            {
                NSUInteger index = [self.hashtagArray indexOfObject:tag];
                
                if( index != NSNotFound )
                {
                    [self.hashtagDict setObject:@"selected" forKey:@(index)];
                }
            }
            
            for( id key in self.hashtagDict )
            {
                [self.selectedHashtags removeObject:[self.hashtagArray objectAtIndex:[key intValue]]];
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType != eErrorTypeRequestCancelled )
            {
                
            }
        }];
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
    
    return [newHashtags copy];
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
        
        cell.userInteractionEnabled = YES;
        cell.accessoryView = nil;
        
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
    label.text = @"What didn't you like about the dish?";
    label.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (IBAction)doneWithHashtags:(UIBarButtonItem *)sender
{
    for( id key in self.hashtagDict )
    {
        [self.selectedHashtags addObject:[self.hashtagArray objectAtIndex:[key intValue]]];
    }
    
    self.review.hashtags = self.selectedHashtags;
    
    for( UIViewController *vc in self.navigationController.viewControllers )
    {
        if( [vc isMemberOfClass:[DAReviewFormViewController class]] )
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
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