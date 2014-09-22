//
//  DANewsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsViewController.h"
#import "DAAppDelegate.h"
#import "DAAPIManager.h"
#import "UIImageView+DishProgress.h"
#import "DAUserNews.h"
#import "NSAttributedString+Dished.h"


@interface DANewsViewController()

@property (strong, nonatomic) NSArray *newsData;
@property (strong, nonatomic) NSArray *followingData;

@end


@implementation DANewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.hidden = YES;
    
    [[DAAPIManager sharedManager] getUserNewsWithCompletion:^( id response, NSError *error )
    {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        self.tableView.hidden = NO;
        
        if( !response || error )
        {
            
        }
        else
        {
            self.newsData = [self newsDataWithData:response];
            [self.tableView reloadData];
        }
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DANewsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newsCell"];
}

- (NSArray *)newsDataWithData:(id)data
{
    NSArray *response = data[@"data"][@"activity_user"];
    NSMutableArray *news = [NSMutableArray array];
    
    if( response && ![response isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in response )
        {
            [news addObject:[DAUserNews userNewsWithData:dataObject]];
        }
    }
    
    return news;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DANewsTableViewCell *newsCell = (DANewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    DAUserNews *news = [self.newsData objectAtIndex:indexPath.row];
    
    if( news.user_img_thumb )
    {
        NSURL *url = [NSURL URLWithString:news.user_img_thumb];
        [newsCell.userImageView sd_setImageWithURL:url];
    }
    else
    {
        newsCell.userImageView.image = [UIImage imageNamed:@"avatar"];
    }
    
    newsCell.newsLabel.text = [news formattedString];
    [newsCell.newsLabel sizeToFit];
    
    newsCell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:news.created attributes:[DANewsTableViewCell timeLabelAttributes]];
    
    newsCell.backgroundColor = !news.viewed ? [UIColor unviewedNewsColor] : [UIColor whiteColor];

    return newsCell;
}

@end