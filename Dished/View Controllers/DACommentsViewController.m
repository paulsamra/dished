//
//  DACommentsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACommentsViewController.h"
#import "DAComment.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAExploreDishResultsViewController.h"
#import "DAUserProfileViewController.h"
#import "DAUserManager.h"
#import "DAUserManager.h"
#import "DATagSuggestionTableView.h"

#define kRowLimit 20


@interface DACommentsViewController() <SWTableViewCellDelegate, JSQMessagesKeyboardControllerDelegate, JSQMessagesInputToolbarDelegate, UITextViewDelegate, DACommentTableViewCellDelegate, DATagSuggestionsTableViewDelegate>

@property (strong, nonatomic) NSDictionary                  *linkedTextAttributes;
@property (strong, nonatomic) NSMutableArray                *comments;
@property (strong, nonatomic) NSURLSessionTask              *loadCommentsTask;
@property (strong, nonatomic) DATagSuggestionTableView      *tagTableView;
@property (strong, nonatomic) UIActivityIndicatorView       *spinner;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@property (nonatomic) BOOL commentsLoaded;
@property (nonatomic) BOOL hasMoreComments;
@property (nonatomic) BOOL isOwnReview;

@end


@implementation DACommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.commentsLoaded = NO;
    self.hasMoreComments = NO;
    self.linkedTextAttributes = [NSAttributedString linkedTextAttributesWithFontSize:15.0f];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
    self.inputToolbar.contentView.textView.placeHolder = @"Add Comment";
    self.inputToolbar.contentView.textView.delegate = self;
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17];
    self.inputToolbar.contentView.textView.keyboardType = UIKeyboardTypeTwitter;
    
    self.keyboardController = [[JSQMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView contextView:self.view panGestureRecognizer:self.tableView.panGestureRecognizer delegate:self];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DACommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"commentCell"];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self loadComments];
}

- (void)loadComments
{
    __weak typeof( self ) weakSelf = self;
    
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    
    NSInteger reviewID = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
    NSDictionary *parameters = @{ kIDKey : @(reviewID), kRowLimitKey : @(kRowLimit), @"sort_dir" : @"desc" };
    
    weakSelf.loadCommentsTask = [[DAAPIManager sharedManager] GETRequest:kCommentsURL withParameters:parameters
    success:^( id response )
    {
        [weakSelf.spinner stopAnimating];
        [weakSelf.spinner removeFromSuperview];
        
        weakSelf.comments = [weakSelf commentsFromResponse:response includeFirstComment:YES];
        
        weakSelf.hasMoreComments = weakSelf.comments.count - 1 < kRowLimit ? NO : YES;
        
        if( !weakSelf.commentsLoaded )
        {
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            weakSelf.commentsLoaded = YES;
        }
        else
        {
            [weakSelf.tableView reloadData];
        }
        
        [weakSelf scrollTableViewToBottom];
        
        weakSelf.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadComments];
        }
    }];
}

- (void)loadMoreComments
{
    __weak typeof( self ) weakSelf = self;
    
    NSInteger reviewID = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
    NSDictionary *parameters = @{ kIDKey : @(reviewID), kRowOffsetKey : @(weakSelf.comments.count - 1),
                                  kRowLimitKey : @(kRowLimit), @"sort_dir" : @"desc" };
    
    weakSelf.loadCommentsTask = [[DAAPIManager sharedManager] GETRequest:kCommentsURL withParameters:parameters
    success:^( id response )
    {
        NSArray *newComments = [weakSelf commentsFromResponse:response includeFirstComment:NO];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 1, newComments.count )];
        [weakSelf.comments insertObjects:newComments atIndexes:indexSet];
        
        UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:99];
        [spinner stopAnimating];

        weakSelf.hasMoreComments = newComments.count < kRowLimit ? NO : YES;
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadMoreComments];
        }
        else
        {
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:99];
            [spinner stopAnimating];
            
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                weakSelf.hasMoreComments = NO;
            }
            
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComments) name:kNetworkReachableKey object:nil];
}

- (void)setupTagTableView
{
    CGFloat y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    CGFloat height = self.inputToolbar.frame.origin.y - y;
    self.tagTableView = [[DATagSuggestionTableView alloc] initWithFrame:CGRectMake( 0, y, self.view.frame.size.width, height)];
    self.tagTableView.suggestionDelegate = self;
    self.tagTableView.hidden = YES;
    [self.view insertSubview:self.tagTableView belowSubview:self.inputToolbar];
}

- (void)didSelectUsernameWithName:(NSString *)name
{
    [self didSelectSuggestion:name withPrefix:@"@"];
}

- (void)didSelectHashtagWithName:(NSString *)name
{
    [self didSelectSuggestion:name withPrefix:@"#"];
}

- (void)didSelectSuggestion:(NSString *)suggestion withPrefix:(NSString *)prefix
{
    self.tagTableView.hidden = YES;
    [self.tagTableView resetTable];
    
    NSString *text = self.inputToolbar.contentView.textView.text;
    
    NSRange lastAt = [text rangeOfString:prefix options:NSBackwardsSearch];
    lastAt.location++;
    lastAt.length = ( text.length ) - lastAt.location;
    
    NSString *updatedText = [text stringByReplacingCharactersInRange:lastAt withString:suggestion];
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    
    self.inputToolbar.contentView.textView.text = [NSString stringWithFormat:@"%@ ", updatedText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if( newString.length == 0 )
    {
        return YES;
    }
    
    NSRange lastSpace = [newString rangeOfString:@" " options:NSBackwardsSearch];
    
    if( lastSpace.location != NSNotFound )
    {
        if( lastSpace.location != newString.length - 1  )
        {
            NSString *substring = [newString substringFromIndex:lastSpace.location + 1];
            
            if( substring.length > 1 )
            {
                if( [substring characterAtIndex:0] == '@' )
                {
                    [self showTagTableWithUsernameQuery:[substring substringFromIndex:1]];
                }
                else if( [substring characterAtIndex:0] == '#' )
                {
                    [self showTagTableWithHashtagQuery:[substring substringFromIndex:1]];
                }
            }
            else
            {
                [self hideTagTableView];
            }
        }
        else
        {
            [self hideTagTableView];
        }
    }
    else if( newString.length > 1 )
    {
        if( [newString characterAtIndex:0] == '@' )
        {
            [self showTagTableWithUsernameQuery:[newString substringFromIndex:1]];
        }
        else if( [newString characterAtIndex:0] == '#' )
        {
            [self showTagTableWithHashtagQuery:[newString substringFromIndex:1]];
        }
    }
    else
    {
        [self hideTagTableView];
    }
    
    return YES;
}

- (void)showTagTableWithUsernameQuery:(NSString *)query
{
    NSRange invalidRange = [query rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    
    if( invalidRange.location == NSNotFound )
    {
        [self.tagTableView updateUsernameSuggestionsWithQuery:query];
        
        if( [self.tagTableView numberOfRowsInSection:0] > 0 )
        {
            self.tagTableView.hidden = NO;
        }
        else
        {
            self.tagTableView.hidden = YES;
        }
    }
    else
    {
        [self hideTagTableView];
    }
}

- (void)showTagTableWithHashtagQuery:(NSString *)query
{
    NSRange invalidRange = [query rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    
    if( invalidRange.location == NSNotFound )
    {
        [self.tagTableView updateHashtagSuggestionsWithQuery:query];

        if( [self.tagTableView numberOfRowsInSection:0] > 0 )
        {
            self.tagTableView.hidden = NO;
        }
    }
    else
    {
        [self hideTagTableView];
    }
}

- (void)hideTagTableView
{
    self.tagTableView.hidden = YES;
    [self.tagTableView resetTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( !self.tagTableView )
    {
        [self setupTagTableView];
    }
    
    [self.keyboardController beginListeningForKeyboard];
    
    [self.inputToolbar.contentView.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    if( self.shouldShowKeyboard )
    {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        self.shouldShowKeyboard = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.keyboardController endListeningForKeyboard];
}

- (void)dealloc
{
    [self.inputToolbar.contentView.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:nil];
    
    [self.keyboardController endListeningForKeyboard];
    [self.loadCommentsTask cancel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (NSMutableArray *)commentsFromResponse:(id)response includeFirstComment:(BOOL)include
{
    NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
    NSMutableArray *comments = [NSMutableArray array];
    
    if( data )
    {
        self.isOwnReview = [nilOrJSONObjectForKey( data, @"is_creator" ) boolValue];

        NSArray *commentsData = nilOrJSONObjectForKey( data, kCommentsKey );
        
        if( commentsData.count == 0 )
        {
            return comments;
        }
        
        if( include )
        {
            [comments addObject:[DAComment commentWithData:commentsData[0]]];
        }
        
        for( NSInteger i = commentsData.count - 1; i > 0; i-- )
        {
            [comments addObject:[DAComment commentWithData:commentsData[i]]];
        }
    }
    
    return comments;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.comments.count;
    count = self.hasMoreComments ? count + 1 : count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DACommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    
    if( indexPath.row == 1 && self.hasMoreComments )
    {
        return [tableView dequeueReusableCellWithIdentifier:@"viewPreviousCell"];
    }
    
    NSInteger realIndex = indexPath.row;
    realIndex = realIndex == 0 ? realIndex : ( self.hasMoreComments ? realIndex - 1 : realIndex );
    
    DAComment *comment = [self.comments objectAtIndex:realIndex];
    
    NSAttributedString *commentString = [comment attributedCommentStringWithFont:[UIFont fontWithName:kHelveticaNeueLightFont size:14.0f]];
    NSArray *usernameMentions = [comment.usernameMentions arrayByAddingObject:comment.creator_username];
    
    [cell.commentTextView setAttributedText:commentString withAttributes:self.linkedTextAttributes knownUsernames:usernameMentions useCache:NO];
    
    NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    cell.rightUtilityButtons = [self utilityButtonsAtIndexPath:indexPath];
    
    cell.delegate = self;
    cell.textViewTapDelegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 && self.hasMoreComments )
    {
        return 44.0;
    }
    
    NSInteger realIndex = indexPath.row;
    realIndex = realIndex == 0 ? realIndex : ( self.hasMoreComments ? realIndex - 1 : realIndex );
    
    DAComment *comment = [self.comments objectAtIndex:realIndex];
    
    static DACommentTableViewCell *sizingCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sizingCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    });
    
    UITextView *textView = sizingCell.commentTextView;
    
    CGFloat textViewRightMargin = sizingCell.frame.size.width - ( textView.frame.origin.x + textView.frame.size.width );
    CGFloat textViewWidth = tableView.frame.size.width - textView.frame.origin.x - textViewRightMargin;
    
    NSAttributedString *commentString = [comment attributedCommentStringWithFont:[UIFont fontWithName:kHelveticaNeueLightFont size:14.0f]];
    
    sizingCell.commentTextView.attributedText = commentString;
    
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    
    CGSize stringSize = [sizingCell.commentTextView sizeThatFits:boundingSize];
    
    CGFloat textViewTopMargin = textView.frame.origin.y;
    CGFloat textViewBottomMargin = sizingCell.frame.size.height - ( textView.frame.origin.y + textView.frame.size.height );
    CGFloat textViewHeight = ceilf( stringSize.height );
    
    CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
    
    if( calculatedHeight < 44.0 )
    {
        calculatedHeight = 44.0;
    }
    
    return calculatedHeight;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (NSArray *)utilityButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *buttons = [NSMutableArray array];
    
    if( indexPath.row == 0 || ( indexPath.row == 1 && self.hasMoreComments ) )
    {
        return buttons;
    }
    
    NSInteger realIndex = indexPath.row;
    realIndex = realIndex == 0 ? realIndex : ( self.hasMoreComments ? realIndex - 1 : realIndex );
    
    DAComment *comment = [self.comments objectAtIndex:realIndex];
    BOOL ownComment = comment.creator_id == [DAUserManager sharedManager].user_id;
    
    UIImage *deleteImage = [UIImage imageNamed:@"delete_comment"];
    UIImage *flagImage   = [UIImage imageNamed:@"flag_comment"];
    
    if( !ownComment )
    {
        [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:flagImage];
    }
    
    if( ownComment || self.isOwnReview )
    {
        [buttons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1] icon:deleteImage];
    }
    
    return buttons;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 && self.hasMoreComments )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:99];
        
        if( !spinner.isAnimating )
        {
            [spinner startAnimating];
            
            [self loadMoreComments];
        }
    }
}

- (void)textViewTapped:(NSString *)text textType:(eLinkedTextType)textType inCell:(DACommentTableViewCell *)inCell
{
    if( textType == eLinkedTextTypeHashtag )
    {
        DAExploreDishResultsViewController *exploreResultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreResults"];
        exploreResultsViewController.searchTerm = text;
        [self.navigationController pushViewController:exploreResultsViewController animated:YES];
    }
    else if( textType == eLinkedTextTypeUsername )
    {
        [self pushUserProfileWithUsername:text];
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSUInteger commentIndex = self.hasMoreComments ? indexPath.row - 1 : indexPath.row;
    DAComment *comment = [self.comments objectAtIndex:commentIndex];
    
    BOOL ownComment = comment.creator_id == [DAUserManager sharedManager].user_id;
    
    if( ownComment )
    {
        [self deleteComment:comment];
        [self.comments removeObjectAtIndex:commentIndex];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        if( index == 0 )
        {
            [self flagComment:comment];
            [cell hideUtilityButtonsAnimated:YES];
        }
        else
        {
            [self deleteComment:comment];
            [self.comments removeObjectAtIndex:commentIndex];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void)deleteComment:(DAComment *)comment
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(comment.comment_id) };
    
    [[DAAPIManager sharedManager] POSTRequest:kDeleteCommentURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.feedItem.num_comments = @( [weakSelf.feedItem.num_comments integerValue] - 1 );
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        shouldRetry ? [weakSelf deleteComment:comment] : [weakSelf loadComments];
    }];
}

- (void)flagComment:(DAComment *)comment
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(comment.comment_id) };
    
    [[DAAPIManager sharedManager] POSTRequest:kFlagCommentURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf flagComment:comment];
        }
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
    
    self.tagTableView.hidden = YES;
    [self.tagTableView resetTable];
    
    DAComment *newComment = [[DAComment alloc] init];
    newComment.comment = commentText;
    newComment.creator_username = [[DAUserManager sharedManager] username];
    newComment.img_thumb = [[DAUserManager sharedManager] img_thumb];
    newComment.creator_type = [[DAUserManager sharedManager] userType];
    newComment.creator_id = [[DAUserManager sharedManager] user_id];
    newComment.usernameMentions = @[ newComment.creator_username ];
    [self.comments addObject:newComment];
    [self.tableView reloadData];
    [self scrollTableViewToBottom];
    
    [self sendCommentWithText:commentText atIndex:self.comments.count - 1];
    
    self.inputToolbar.contentView.textView.text = nil;
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)sendCommentWithText:(NSString *)text atIndex:(NSUInteger)index
{    
    __weak typeof( self ) weakSelf = self;
    
    NSInteger reviewID = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
    NSDictionary *parameters = @{ kIDKey : @(reviewID), kCommentKey : text };
    
    [[DAAPIManager sharedManager] POSTRequest:kCommentsURL withParameters:parameters
    success:^( id responseObject )
    {
        NSDictionary *createdComment = nilOrJSONObjectForKey( responseObject, kDataKey );
        DAComment *comment = self.comments[index];
        NSArray *usernameMentions = nilOrJSONObjectForKey( createdComment, @"usernames" );
        
        if( [usernameMentions isKindOfClass:[NSArray class]] )
        {
            comment.usernameMentions = usernameMentions;
        }
        
        [self.tableView reloadData];
        
        weakSelf.feedItem.num_comments = @( [weakSelf.feedItem.num_comments integerValue] + 1 );
        
        NSString *idName = [NSString stringWithFormat:@"%d", (int)reviewID];
        [[NSNotificationCenter defaultCenter] postNotificationName:idName object:nil];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        shouldRetry ? [weakSelf sendCommentWithText:text atIndex:index] : [weakSelf loadComments];
    }];
}

@end