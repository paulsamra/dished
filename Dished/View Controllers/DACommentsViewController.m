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


@interface DACommentsViewController() <SWTableViewCellDelegate, JSQMessagesKeyboardControllerDelegate, JSQMessagesInputToolbarDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSArray                       *comments;
@property (strong, nonatomic) UIActivityIndicatorView       *spinner;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@end


@implementation DACommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
    self.inputToolbar.contentView.textView.placeHolder = @"Add Comment";
    self.inputToolbar.contentView.textView.delegate = self;
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    self.keyboardController = [[JSQMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView contextView:self.view panGestureRecognizer:self.tableView.panGestureRecognizer delegate:self];
    
    [[DAAPIManager sharedManager] getCommentsForReviewID:self.reviewID completion:^( id response, NSError *error )
    {
        [self.spinner stopAnimating];
        [self.spinner removeFromSuperview];
        
        if( error || !response )
        {
            
        }
        else
        {
            self.comments = [self commentsFromResponse:response];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self scrollTableViewToBottom];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshComments) name:kNetworkReachableKey object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.keyboardController beginListeningForKeyboard];
    
    [self.inputToolbar.contentView.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.keyboardController endListeningForKeyboard];
    
    [self.inputToolbar.contentView.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:nil];
    
    [super viewDidDisappear:animated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (NSArray *)commentsFromResponse:(id)response
{
    NSArray *data = response[@"data"];
    NSMutableArray *comments = [NSMutableArray array];
    
    if( data && ![data isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in [data reverseObjectEnumerator] )
        {
            [comments addObject:[DAComment commentWithData:dataObject]];
        }
    }
    
    return [comments copy];
}

- (void)refreshComments
{
    [[DAAPIManager sharedManager] getCommentsForReviewID:self.reviewID completion:^( id response, NSError *error )
    {
        if( error || !response )
        {
            
        }
        else
        {
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
            
            self.comments = [self commentsFromResponse:response];
            [self.tableView reloadData];
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
    
    cell.delegate = self;
    
    return cell;
}

- (NSArray *)utilityButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *buttons = [NSMutableArray array];
    
    UIImage *deleteImage = [UIImage imageNamed:@"delete_comment"];
    UIImage *flagImage   = [UIImage imageNamed:@"flag_comment"];
    
    [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:flagImage];
    [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:deleteImage];
    
    return buttons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    NSAttributedString *commentString = [self commentStringForComment:comment];
    
    CGRect commentRect = [commentString boundingRectWithSize:CGSizeMake( self.view.frame.size.width - 60, CGFLOAT_MAX )
                                 options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                 context:nil];
    
    CGFloat minimumCellHeight = ceilf( commentRect.size.height ) + 25;
    
    return minimumCellHeight < tableView.rowHeight ? tableView.rowHeight : minimumCellHeight;
}

- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [labelString appendAttributedString:influencerIconString];
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }]];
    
    return labelString;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    if( index == 0 )
    {
        [self flagComment:comment];
        [cell hideUtilityButtonsAnimated:YES];
    }
    else
    {
        [self deleteComment:comment];
        
        NSMutableArray *mutableComments = [self.comments mutableCopy];
        [mutableComments removeObjectAtIndex:indexPath.row];
        self.comments = [mutableComments copy];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)deleteComment:(DAComment *)comment
{
    [[DAAPIManager sharedManager] deleteCommentWithID:comment.comment_id completion:^( BOOL success )
    {
        [self refreshComments];
    }];
}

- (void)flagComment:(DAComment *)comment
{
    [[DAAPIManager sharedManager] flagCommentWithID:comment.comment_id completion:^( BOOL success )
    {
        [self refreshComments];
    }];
}

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    CGFloat heightFromBottom = CGRectGetHeight( self.tableView.frame ) - CGRectGetMinY( keyboardFrame ) - self.tabBarController.tabBar.frame.size.height;
    
    if( heightFromBottom < 0 )
    {
        heightFromBottom = 0;
    }
    
    self.toolbarBottomConstraint.constant = heightFromBottom;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    [self adjustTableViewInsets];
    [self scrollTableViewToBottom];
}

- (void)adjustTableViewInsets
{
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    tableViewInsets.bottom = self.view.frame.size.height - self.inputToolbar.frame.origin.y;
    self.tableView.contentInset = tableViewInsets;
}

- (void)scrollTableViewToBottom
{
    if( self.comments.count == 0 )
    {
        return;
    }
    
    NSIndexPath *lastRowPath = [NSIndexPath indexPathForRow:self.comments.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastRowPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self didPressSendButton];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    //no implementation needed
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( object == self.inputToolbar.contentView.textView )
    {
        CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        CGFloat change = newContentSize.height - oldContentSize.height;
        
        [self adjustInputToolbarWithSizeChange:change];
        
        [self adjustTableViewInsets];
    }
}

- (void)adjustInputToolbarWithSizeChange:(CGFloat)change
{
    BOOL contentSizeIsIncreasing = change > 0;
    
    if( CGRectGetMinY( self.inputToolbar.frame ) == self.topLayoutGuide.length )
    {
        BOOL contentOffsetIsPositive = ( self.inputToolbar.contentView.textView.contentOffset.y > 0 );
        
        if( contentSizeIsIncreasing || contentOffsetIsPositive )
        {
            [self scrollTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - change;
    
    if( newToolbarOriginY <= self.topLayoutGuide.length )
    {
        change = toolbarOriginY - self.topLayoutGuide.length;
        [self scrollTextViewToBottomAnimated:YES];
    }
    
    [self updateToolbarHeightConstraintWithChange:change];
    
    if( change < 0 )
    {
        [self scrollTextViewToBottomAnimated:NO];
    }
}

- (void)scrollTextViewToBottomAnimated:(BOOL)animated
{
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGFloat y = textView.contentSize.height - CGRectGetHeight( textView.bounds);
    CGPoint contentOffsetToShowLastLine = CGPointMake( 0, y );
    
    if( !animated )
    {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01 delay:0.01 options:UIViewAnimationOptionCurveLinear animations:^
    {
        textView.contentOffset = contentOffsetToShowLastLine;
    }
    completion:nil];
}

- (void)updateToolbarHeightConstraintWithChange:(CGFloat)change
{
    self.toolbarHeightConstraint.constant += change;
    
    if( self.toolbarHeightConstraint.constant < kJSQMessagesInputToolbarHeightDefault )
    {
        self.toolbarHeightConstraint.constant = kJSQMessagesInputToolbarHeightDefault;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)didPressSendButton
{
    NSString *commentText = self.inputToolbar.contentView.textView.text;
    
    DAComment *newComment = [[DAComment alloc] init];
    newComment.comment = commentText;
    self.comments = [self.comments arrayByAddingObject:newComment];
    [self.tableView reloadData];
    [self scrollTableViewToBottom];
    
    [self sendCommentWithText:commentText];
    
    self.inputToolbar.contentView.textView.text = nil;
    [self.inputToolbar toggleSendButtonEnabled];
    
    [self.view endEditing:YES];
}

- (void)sendCommentWithText:(NSString *)text
{
    [[DAAPIManager sharedManager] createComment:text forReviewID:self.reviewID completion:^( BOOL success )
    {
        [self refreshComments];
    }];
}

@end