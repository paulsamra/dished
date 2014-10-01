//
//  DAUserProfileViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserProfileViewController.h"
#import "DAAPIManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAExploreDishSearchResult.h"
#import "DADishTableViewCell.h"


@interface DAUserProfileViewController ()

@property (weak,   nonatomic) NSArray *selectedDataSource;
@property (strong, nonatomic) NSArray *foodReviews;
@property (strong, nonatomic) NSArray *cocktailReviews;
@property (strong, nonatomic) NSArray *wineReviews;

@end


@implementation DAUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.dishesTableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActionSheet)];
    self.navigationItem.rightBarButtonItem = moreButton;
    
    [self setMainViewsHidden:YES animated:NO];
    
    if( self.username )
    {
        self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.username];
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    [[DAAPIManager sharedManager] getUserProfileWithUserID:self.user_id completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            
        }
        else
        {
            [self populateUserDataWithResponse:response];
            self.selectedDataSource = self.foodReviews;
            [self.dishesTableView reloadData];
            
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
            [self setMainViewsHidden:NO animated:YES];
        }
    }];
}

- (void)setMainViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if( animated )
    {
        [UIView transitionWithView:self.topView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.topView.hidden = hidden;
        
        [UIView transitionWithView:self.descriptionTextView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.descriptionTextView.hidden = hidden;
        
        [UIView transitionWithView:self.middleView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.middleView.hidden = hidden;
        
        [UIView transitionWithView:self.dishesTableView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.dishesTableView.hidden = hidden;
    }
    else
    {
        self.topView.hidden = hidden;
        self.descriptionTextView.hidden = hidden;
        self.middleView.hidden = hidden;
        self.dishesTableView.hidden = hidden;
    }
}

- (void)populateUserDataWithResponse:(id)response
{
    NSDictionary *data = response[@"data"];
    
    if( data && ![data isEqual:[NSNull null]] )
    {
        [self setTitle:@"Dishes"    withValue:[data[@"num_reviews"]   integerValue] forButton:self.numDishesButton];
        [self setTitle:@"Following" withValue:[data[@"num_following"] integerValue] forButton:self.numFollowingButton];
        [self setTitle:@"Followers" withValue:[data[@"num_followers"] integerValue] forButton:self.numFollowersButton];
        
        NSDictionary *user = data[@"user"];
        
        NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"fname"], user[@"lname"]];
        [self setDescriptionTextWithName:name description:user[@"desc"]];
        
        self.navigationItem.title = [NSString stringWithFormat:@"@%@", user[@"username"]];
        
        NSURL *url = [NSURL URLWithString:nilOrJSONObjectForKey( user, @"img_thumb" )];
        [self.userImageView sd_setImageWithURL:url];
        
        NSDictionary *reviews = data[@"reviews"];
        self.foodReviews      = [self reviewsWithData:nilOrJSONObjectForKey( reviews, @"food" )];
        self.wineReviews      = [self reviewsWithData:nilOrJSONObjectForKey( reviews, @"wine" )];
        self.cocktailReviews  = [self reviewsWithData:nilOrJSONObjectForKey( reviews, @"cocktail" )];
        
        if( ![data[@"is_profile_owner"] boolValue] )
        {
            BOOL isFollowed = [data[@"caller_follows"] boolValue];
            [self setFollowButtonState:isFollowed];
        }
        else
        {
            [self setFollowButtonToProfileOwner];
        }
    }
}

- (NSArray *)reviewsWithData:(id)data
{
    NSMutableArray *reviews = [NSMutableArray array];
    
    for( NSDictionary *review in data )
    {
        [reviews addObject:[DAExploreDishSearchResult dishSearchResultWithData:review]];
    }
    
    return reviews;
}

- (void)setTitle:(NSString *)title withValue:(NSInteger)value forButton:(UIButton *)button
{
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:[NSString stringWithFormat:@"%d\n%@", (int)value, title] forState:UIControlStateNormal];
}

- (void)setFollowButtonState:(BOOL)isFollowed
{
    self.followButton.backgroundColor = isFollowed ? [UIColor clearColor] : [UIColor followButtonColor];
    
    NSString *buttonTitle = isFollowed ? @"Unfollow" : @"Follow";
    [self.followButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    UIColor *titleColor = isFollowed ? [UIColor redColor] : [UIColor whiteColor];
    [self.followButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setFollowButtonToProfileOwner
{
    self.followButton.backgroundColor = [UIColor clearColor];
    [self.followButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    [self.followButton setTitle:@"Edit Your Profile" forState:UIControlStateNormal];
}

- (void)setDescriptionTextWithName:(NSString *)name description:(NSString *)description
{
    NSDictionary *nameAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14] };
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name attributes:nameAttributes];
    
    if( description.length > 0 )
    {
        NSDictionary *descriptionAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14] };
        
        NSMutableAttributedString *descriptionString = [[NSMutableAttributedString alloc] initWithString:description attributes:descriptionAttributes];
        
        [nameString appendAttributedString:[[NSAttributedString alloc] initWithString:@" - " attributes:descriptionAttributes]];
        [nameString appendAttributedString:descriptionString];
    }
    
    self.descriptionTextView.attributedText = nameString;
    
    CGFloat textViewWidth = self.descriptionTextView.frame.size.width;
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    CGRect stringRect = [nameString boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    UIEdgeInsets textViewInsets = self.descriptionTextView.textContainerInset;
    CGFloat heightConstraint = stringRect.size.height + textViewInsets.top + textViewInsets.bottom;
    
    self.descriptionHeightConstraint.constant = heightConstraint;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedDataSource.count == 0 ? 1 : self.selectedDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        cell.textLabel.text = @"No Reviews";
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    DADishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    DAExploreDishSearchResult *result = [self.selectedDataSource objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text          = result.name;
    cell.gradeLabel.text             = result.grade;
    cell.locationNameLabel.text      = result.locationName;
    cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.numComments];
    cell.isExplore = NO;

    NSURL *url = [NSURL URLWithString:result.imageURL];
    [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        return tableView.rowHeight;
    }
    
    return 97;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        return tableView.rowHeight;
    }
    
    return 97;
}

- (IBAction)changeDishType
{
    switch( self.dishTypeChooser.selectedSegmentIndex )
    {
        case 0: self.selectedDataSource = self.foodReviews;     break;
        case 1: self.selectedDataSource = self.cocktailReviews; break;
        case 2: self.selectedDataSource = self.wineReviews;     break;
    }
    
    [self.dishesTableView reloadData];
}

- (void)showMoreActionSheet
{
    
}

- (IBAction)goToDishesMap
{
    
}

- (IBAction)followButtonPressed
{
    
}

- (IBAction)numDishesPressed
{
    
}

- (IBAction)numFollowingPressed
{
    
}

- (IBAction)numFollowersPressed
{
    
}

@end