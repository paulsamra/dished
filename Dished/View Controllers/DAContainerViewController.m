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
@property (strong, nonatomic) DAMenuViewController   *menuViewController;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL menuIsShowing;

@end


@implementation DAContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews
{
    self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    
    [self.view addSubview:self.tabBarController.view];
    [self addChildViewController:self.tabBarController];
    [self.tabBarController didMoveToParentViewController:self];
    
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    
    [self.view addSubview:self.menuViewController.view];
    [self.view sendSubviewToBack:self.menuViewController.view];
    [self addChildViewController:self.menuViewController];
    [self.menuViewController didMoveToParentViewController:self];
    
    self.menuViewController.view.frame = CGRectMake( kMenuHorizontalOffset, 0, self.view.frame.size.width - kMenuHorizontalOffset, self.view.frame.size.height );
}

- (void)slideOutMenu
{
    if( self.menuIsShowing )
    {
        return;
    }
    
    self.menuIsShowing = YES;
    
    [self addGestureRecognizers];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        CGFloat x = -self.view.frame.size.width + kMenuHorizontalOffset;
        self.tabBarController.view.frame = CGRectMake( x, 0, self.view.frame.size.width, self.view.frame.size.height );
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
    completion:nil];
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


//- (void)panGestureDidMove:(UIPanGestureRecognizer *)sender
//{
//    [sender.view.layer removeAllAnimations];
//    
//    CGPoint translatedPoint = [sender translationInView:self.view];
//    CGPoint velocity = [sender velocityInView:sender.view];
//    
//    if( sender.state == UIGestureRecognizerStateBegan )
//    {
//        UIView *childView = nil;
//        
//        if( velocity.x > 0 )
//        {
//            if( !self.menuIsShowing )
//            {
//                childView = self.tabBarController.view;
//                [self moveToTabBar];
//            }
//        }
//    }
//    
//    if( sender.state == UIGestureRecognizerStateEnded )
//    {
//        if( !_showPanel )
//        {
//            [self movePanelToOriginalPosition];
//        }
//        else
//        {
//            if (_showingLeftPanel) {
//                [self movePanelRight];
//            }  else if (_showingRightPanel) {
//                [self movePanelLeft];
//            }
//        }
//    }
//    
//    if( sender.state == UIGestureRecognizerStateChanged )
//    {
//        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
//        _showPanel = abs([sender view].center.x - _centerViewController.view.frame.size.width/2) > _centerViewController.view.frame.size.width/2;
//        
//        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
//        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
//        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
//        
//        // If you needed to check for a change in direction, you could use this code to do so.
//        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
//            // NSLog(@"same direction");
//        } else {
//            // NSLog(@"opposite direction");
//        }
//        
//        _preVelocity = velocity;
//}

- (void)removeGestureRecognizers
{
    [self.blockingView removeFromSuperview];
}

- (void)moveToMenu
{
    
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