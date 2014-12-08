//
//  DAContainerViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/19/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAContainerViewController.h"
#import "DATabBarController.h"
#import "DAMenuViewController.h"

#define kAnimationDuration    0.25
#define kMenuHorizontalOffset 60


@interface DAContainerViewController() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView                 *blockingView;
@property (strong, nonatomic) DATabBarController     *tabBarController;
@property (strong, nonatomic) UINavigationController *menuViewController;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL menuIsShowing;
@property (nonatomic) BOOL menuIsMainView;

@end


@implementation DAContainerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupViews];
}

- (void)setupViews
{
    self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    
    [self.view addSubview:self.tabBarController.view];
    [self addChildViewController:self.tabBarController];
    [self.tabBarController didMoveToParentViewController:self];
    
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuNav"];
    
    [self.view addSubview:self.menuViewController.view];
    [self.view sendSubviewToBack:self.menuViewController.view];
    [self addChildViewController:self.menuViewController];
    [self.menuViewController didMoveToParentViewController:self];
    self.menuViewController.view.hidden = YES;
    
    self.menuViewController.view.frame = CGRectMake( kMenuHorizontalOffset, 0, self.view.frame.size.width - kMenuHorizontalOffset, self.view.frame.size.height );
}

- (BOOL)menuShowing
{
    return self.menuIsShowing;
}

- (void)slideOutMenu
{
    if( self.menuIsShowing && !self.menuIsMainView )
    {
        return;
    }
    
    self.menuIsMainView = NO;
    self.menuIsShowing = YES;
    self.menuViewController.view.hidden = NO;
    
    [self addGestureRecognizers];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        CGFloat x = -self.view.frame.size.width + kMenuHorizontalOffset;
        self.tabBarController.view.frame = CGRectMake( x, 0, self.view.frame.size.width, self.view.frame.size.height );
        self.menuViewController.view.frame = CGRectMake( kMenuHorizontalOffset, 0, self.view.frame.size.width - kMenuHorizontalOffset, self.view.frame.size.height );
    }
    completion:nil];
}

- (void)moveToTabBar
{
    if( !self.menuIsShowing )
    {
        return;
    }
    
    self.menuIsShowing = NO;
    
    [self removeGestureRecognizers];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        self.tabBarController.view.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height );
    }
    completion:^( BOOL finished )
    {
        self.menuViewController.view.hidden = YES;
    }];
}

- (void)addGestureRecognizers
{
    if( !self.blockingView )
    {
        self.blockingView = [[UIView alloc] initWithFrame:self.tabBarController.view.frame];
        [self addTapGestureRecognizer];
        [self addPanGestureRecognizer];
    }
    
    [self.tabBarController.view addSubview:self.blockingView];
}

- (void)addTapGestureRecognizer
{
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveToTabBar)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;

    [self.blockingView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)addPanGestureRecognizer
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDidMove:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    
    [self.blockingView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)panGestureDidMove:(UIPanGestureRecognizer *)gesture
{
    UIView *piece = gesture.view.superview;
    [self adjustAnchorPointForGestureRecognizer:gesture];
        
    if( gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged )
    {
        CGPoint translation = [gesture translationInView:piece.superview];
        
        [piece setCenter:CGPointMake( piece.center.x + translation.x, piece.center.y )];
        [gesture setTranslation:CGPointZero inView:piece.superview];
    }
    else if( [gesture state] == UIGestureRecognizerStateEnded )
    {
        [self moveToTabBar];
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        UIView *piece = gestureRecognizer.view.superview;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake( locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height );
        piece.center = locationInSuperview;
    }
}

- (void)removeGestureRecognizers
{
    [self.blockingView removeFromSuperview];
}

- (void)moveToMenu
{
    if( self.menuIsMainView )
    {
        return;
    }
    
    self.menuIsMainView = YES;
    self.menuIsShowing = YES;
    
    self.menuViewController.view.hidden = NO;
    [self removeGestureRecognizers];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        self.menuViewController.view.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height );
        [self.menuViewController.view layoutIfNeeded];
        self.tabBarController.view.frame = CGRectMake( -self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height );
    }
    completion:nil];
}

- (void)handleUserNotificationWithUserID:(NSInteger)userID isRestaurant:(BOOL)isRestaurant
{
    self.tabBarController.selectedIndex = 3;
    
    if( isRestaurant )
    {
        [self.tabBarController.selectedViewController pushrestaurantProfileWithUserID:userID username:nil];
    }
    else
    {
        [self.tabBarController.selectedViewController pushUserProfileWithUserID:userID];
    }
}

- (void)handleReviewNotificationWithReviewID:(NSInteger)reviewID
{
    self.tabBarController.selectedIndex = 3;
    
    [self.tabBarController.selectedViewController pushReviewDetailsWithReviewID:reviewID];
}

@end


@implementation UIViewController(DAContainerViewController)

- (DAContainerViewController *)containerViewController
{
    UIViewController *parent = self;
    Class revealClass = [DAContainerViewController class];
    while( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:revealClass] ) {}
    return (id)parent;
}

@end