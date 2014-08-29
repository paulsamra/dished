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
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[DAAPIManager sharedManager] getCommentsForReviewID:self.reviewID completion:^( id response, NSError *error )
    {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        
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

    cell.commentTextView.attributedText = [self commentStringForComment:comment];
    
    NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL];
    
    cell.rightUtilityButtons = [self utilityButtonsAtIndexPath:indexPath];
        
    return cell;
}

- (NSArray *)utilityButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *buttons = [NSMutableArray array];
    
    UIImage *deleteImage = [UIImage imageNamed:@"comment_delete"];
    UIImage *flagImage   = [UIImage imageNamed:@"comment_flag"];
    
    [buttons sw_addUtilityButtonWithColor:[UIColor redColor] icon:deleteImage];
    [buttons sw_addUtilityButtonWithColor:[UIColor redColor] icon:flagImage];
    
    return buttons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    NSAttributedString *commentString = [self commentStringForComment:comment];
    
    CGRect commentRect = [commentString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 60, CGFLOAT_MAX)
                                 options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                 context:nil];
    
    CGFloat minimumCellHeight = ceilf( commentRect.size.height ) + 20;
    
    CGFloat ret = minimumCellHeight < tableView.rowHeight ? tableView.rowHeight : minimumCellHeight;
    return ret;
}

- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f] }];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [labelString appendAttributedString:influencerIconString];
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f] }]];
    
    return labelString;
}

@end