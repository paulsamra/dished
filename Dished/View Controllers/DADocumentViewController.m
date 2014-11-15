//
//  DADocumentViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADocumentViewController.h"


@interface DADocumentViewController() <UIWebViewDelegate>

@end


@implementation DADocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.documentName;
    self.webView.delegate = self;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem.customView = spinner;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = barButton;
    [spinner startAnimating];
    
    if( self.documentURL )
    {
        dispatch_async( dispatch_get_main_queue(), ^
        {
            NSString *urlAddress = self.documentURL;
            NSURL *url = [NSURL URLWithString:urlAddress];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:urlRequest];
        });
    }
    else
    {
        dispatch_async( dispatch_get_main_queue(), ^
        {
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:self.documentName ofType:@"html"];
            NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
            [self.webView loadHTMLString:htmlString baseURL:nil];
        });
    }
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
    
    if( self.presentingViewController )
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

@end