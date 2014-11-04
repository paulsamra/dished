//
//  DACommentsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACommentsViewController.h"
#import "DAComment.h"
#import "DAAPIManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAExploreDishResultsViewController.h"
#import "DAUserProfileViewController.h"
#import "DAUserManager.h"
#import "DAUserManager.h"


@interface DACommentsViewController() <SWTableViewCellDelegate, JSQMessagesKeyboardControllerDelegate, JSQMessagesInputToolbarDelegate, UITextViewDelegate, DACommentTableViewCellDelegate>

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
    
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    [[DAAPIManager sharedManager] getCommentsForReviewID:reviewID completion:^( id response, NSError *error )
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DACommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"commentCell"];
    
    self.tableView.estimatedRowHeight = 44.0;
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
    
    if( self.shouldShowKeyboard )
    {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.keyboardController endListeningForKeyboard];
    
    [self.inputToolbar.contentView.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:nil];
}

- (void)dealloc
{
    [self.keyboardController endListeningForKeyboard];
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
        for( NSDictionary *dataObject in data )
        {
            [comments addObject:[DAComment commentWithData:dataObject]];
        }
    }
    
    return [comments copy];
}

- (void)refreshComments
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    [[DAAPIManager sharedManager] getCommentsForReviewID:reviewID completion:^( id response, NSError *error )
    {
        if( error || !response )
        {
            
        }
        else
        {
            self.comments = [self commentsFromResponse:response];
            [self.tableView reloadData];
            [self scrollTableViewToBottom];
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
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    cell.rightUtilityButtons = [self utilityButtonsAtIndexPath:indexPath];
    
    cell.delegate = self;
    cell.textViewTapDelegate = self;
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    static DACommentTableViewCell *sizingCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sizingCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    });
    
    UITextView *textView = sizingCell.commentTextView;
    
    CGFloat textViewRightMargin = sizingCell.frame.size.width - ( textView.frame.origin.x + textView.frame.size.width );
    CGFloat textViewWidth = tableView.frame.size.width - textView.frame.origin.x - textViewRightMargin;
    
    NSAttributedString *commentString = [self commentStringForComment:comment];
    
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    CGRect stringRect   = [commentString boundingRectWithSize:boundingSize
                                                      options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                                      context:nil];
    
    CGFloat textViewTopMargin = textView.frame.origin.y;
    CGFloat textViewBottomMargin = sizingCell.frame.size.height - ( textView.frame.origin.y + textView.frame.size.height );
    CGFloat textViewHeight = ceilf( stringRect.size.height ) + 2;
    
    CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
    
    if( calculatedHeight < 44.0 )
    {
        calculatedHeight = 44.0;
    }
    
    return calculatedHeight;
}

- (NSArray *)utilityButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *buttons = [NSMutableArray array];
    
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    BOOL ownComment = comment.creator_id == [DAUserManager sharedManager].user_id;
    
    UIImage *deleteImage = [UIImage imageNamed:@"delete_comment"];
    UIImage *flagImage   = [UIImage imageNamed:@"flag_comment"];
    
    if( !ownComment )
    {
        [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:flagImage];
    }
    
    if( ownComment )
    {
        [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:deleteImage];
    }
    
    return buttons;
}

- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] }];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [labelString appendAttributedString:influencerIconString];
    }
    
    NSArray *words = [comment.comment componentsSeparatedByString:@" "];
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] }];
    
    for( NSString *word in words )
    {
        if( [word hasPrefix:@"#"] || [word hasPrefix:@"@"] )
        {
            NSRange matchRange = [comment.comment rangeOfString:word];
            [commentString setAttributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] } range:matchRange];
        }
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:commentString];
    
    return labelString;
}

- (void)textViewTapped:(NSInteger)characterIndex cell:(DACommentTableViewCell *)cell
{
    eLinkedTextType linkedTextType = [cell.commentTextView linkedTextTypeForCharacterAtIndex:characterIndex];
    
    if( linkedTextType == eLinkedTextTypeHashtag )
    {
        DAExploreDishResultsViewController *exploreResultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreResults"];
        exploreResultsViewController.searchTerm = [cell.commentTextView linkedTextForCharacterAtIndex:characterIndex];
        [self.navigationController pushViewController:exploreResultsViewController animated:YES];
    }
    else if( linkedTextType == eLinkedTextTypeUsername )
    {
        DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        userProfileViewController.username = [cell.commentTextView linkedTextForCharacterAtIndex:characterIndex];
        userProfileViewController.isRestaurant = NO;
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
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
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(comment.comment_id) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [[DAAPIManager sharedManager] POST:kFlagCommentURL parameters:parameters success:nil failure:nil];
    }];
}

- (void)keyboardController:(JSQMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    CGFloat heightFromBottom = CGRectGetHeight( self.tableView.frame ) - CGRectGetMinY( keyboardFrame );
    
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
    newComment.creator_username = [[DAUserManager sharedManager] username];
    newComment.img_thumb = [[DAUserManager sharedManager] img_thumb];
    newComment.creator_type = [[DAUserManager sharedManager] userType];
    self.comments = [self.comments arrayByAddingObject:newComment];
    [self.tableView reloadData];
    [self scrollTableViewToBottom];
    
    [self sendCommentWithText:commentText];
    
    self.inputToolbar.contentView.textView.text = nil;
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)sendCommentWithText:(NSString *)text
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    [[DAAPIManager sharedManager] createComment:text forReviewID:reviewID completion:^( BOOL success )
    {
        [self refreshComments];
        
        self.feedItem.num_comments = @( [self.feedItem.num_comments integerValue] + 1 );
    }];
}

@end