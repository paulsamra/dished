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
#import "NSAttributedString+Dished.h"


@interface DACommentsViewController() <SWTableViewCellDelegate, JSQMessagesKeyboardControllerDelegate, JSQMessagesInputToolbarDelegate, UITextViewDelegate, DACommentTableViewCellDelegate, DATagSuggestionsTableViewDelegate>

@property (strong, nonatomic) NSArray                       *comments;
@property (strong, nonatomic) NSDictionary                  *linkedTextAttributes;
@property (strong, nonatomic) NSURLSessionTask              *loadCommentsTask;
@property (strong, nonatomic) DATagSuggestionTableView      *tagTableView;
@property (strong, nonatomic) UIActivityIndicatorView       *spinner;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@property (nonatomic) BOOL commentsLoaded;
@property (nonatomic) BOOL isOwnReview;

@end


@implementation DACommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.commentsLoaded = NO;
    self.linkedTextAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
    
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
    
    self.tableView.estimatedRowHeight = 44.0;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self loadComments];
}

- (void)loadComments
{
    __weak typeof( self ) weakSelf = self;
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSInteger reviewID = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
        NSDictionary *parameters = @{ kIDKey : @(reviewID) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        weakSelf.loadCommentsTask = [[DAAPIManager sharedManager] GET:kCommentsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [weakSelf.spinner stopAnimating];
            [weakSelf.spinner removeFromSuperview];
            
            weakSelf.comments = [weakSelf commentsFromResponse:responseObject];
            
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
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComments) name:kNetworkReachableKey object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if( !self.tagTableView )
    {
        [self setupTagTableView];
    }
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

- (NSArray *)commentsFromResponse:(id)response
{
    NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
    NSMutableArray *comments = [NSMutableArray array];
    
    if( data )
    {
        NSArray *commentsData = nilOrJSONObjectForKey( data, @"comments" );
        
        self.isOwnReview = [nilOrJSONObjectForKey( data, @"is_creator" ) boolValue];
        
        for( NSDictionary *dataObject in commentsData )
        {
            [comments addObject:[DAComment commentWithData:dataObject]];
        }
    }
    
    return [comments copy];
}

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
    
    NSAttributedString *commentString = [self commentStringForComment:comment];
    NSArray *usernameMentions = [comment.usernameMentions arrayByAddingObject:comment.creator_username];
    
    [cell.commentTextView setAttributedText:commentString withAttributes:self.linkedTextAttributes delimiter:nil knownUsernames:usernameMentions];
    
    NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    cell.rightUtilityButtons = [self utilityButtonsAtIndexPath:indexPath];
    
    cell.delegate = self;
    cell.textViewTapDelegate = self;
    
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
    
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    BOOL ownComment = comment.creator_id == [DAUserManager sharedManager].user_id;
    
    UIImage *deleteImage = [UIImage imageNamed:@"delete_comment"];
    UIImage *flagImage   = [UIImage imageNamed:@"flag_comment"];
    
    if( comment.comment_id == 0 )
    {
        return buttons;
    }
    
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

- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSMutableAttributedString *labelString = [[[NSAttributedString alloc] initWithString:usernameString attributes:self.linkedTextAttributes] mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [labelString appendAttributedString:influencerIconString];
    }
    
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] }];
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
        NSString *username = [cell.commentTextView linkedTextForCharacterAtIndex:characterIndex];
        
        [self pushUserProfileWithUsername:username];
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DAComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    BOOL ownComment = comment.creator_id == [DAUserManager sharedManager].user_id;
    
    if( ownComment )
    {
        [self deleteComment:comment];
        
        NSMutableArray *mutableComments = [self.comments mutableCopy];
        [mutableComments removeObjectAtIndex:indexPath.row];
        self.comments = [mutableComments copy];
        
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
            
            NSMutableArray *mutableComments = [self.comments mutableCopy];
            [mutableComments removeObjectAtIndex:indexPath.row];
            self.comments = [mutableComments copy];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void)deleteComment:(DAComment *)comment
{
    __weak typeof( self ) weakSelf = self;
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(comment.comment_id) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
         
        [[DAAPIManager sharedManager] POST:kDeleteCommentURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [weakSelf loadComments];
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            [weakSelf loadComments];
        }];
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
    newComment.creator_id = [[DAUserManager sharedManager] user_id];
    self.comments = [self.comments arrayByAddingObject:newComment];
    [self.tableView reloadData];
    [self scrollTableViewToBottom];
    
    [self sendCommentWithText:commentText];
    
    self.inputToolbar.contentView.textView.text = nil;
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)sendCommentWithText:(NSString *)text
{
    __weak typeof( self ) weakSelf = self;
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSInteger reviewID = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
        NSDictionary *parameters = @{ kIDKey : @(reviewID), kCommentKey : text };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [[DAAPIManager sharedManager] POST:kCommentsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [weakSelf loadComments];
            
            self.feedItem.num_comments = @( [self.feedItem.num_comments integerValue] + 1 );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            [weakSelf loadComments];
        }];
    }];
}

@end