//
//  DACommentsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACommentsViewController.h"
#import "DAComment.h"
#import "DACommentTableViewCell.h"
#import "DAAPIManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DACommentsViewController()

@property (strong, nonatomic) NSArray *comments;

@end


@implementation DACommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    [[DAAPIManager sharedManager] getCommentsForReviewID:self.reviewID completion:^( id response, NSError *error )
    {
        if( error || !response )
        {
            
        }
        else
        {
            self.comments = [self commentsFromResponse:response];
            [self.tableView reloadData];
        }
    }];
}

- (NSArray *)commentsFromResponse:(id)response
{
    NSArray *data = response[@"data"];
    NSMutableArray *comments = [NSMutableArray array];
    
    if( ![data isKindOfClass:[NSArray class]] )
    {
        return [NSArray array];
    }
    
    if( data && ![data isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in data )
        {
            DAComment *comment = [[DAComment alloc] init];
            
            NSTimeInterval timeInterval = [dataObject[@"created"] doubleValue];
            comment.created          = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            comment.comment_id       = [dataObject[@"id"] integerValue];
            comment.creator_id       = [dataObject[@"creator_id"] integerValue];
            comment.comment          = dataObject[@"comment"];
            comment.img_thumb        = nilOrJSONObjectForKey( dataObject, @"img_thumb" );
            comment.creator_type     = dataObject[@"creator_type"];
            comment.creator_username = dataObject[@"creator_username"];
            
            [comments addObject:comment];
        }
    }
    
    return [comments copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DACommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    cell.commentLabel.text = comment.comment;
    [cell.commentLabel sizeToFit];
    
    NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
    [cell.userImageView setImageWithURL:userImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

@end