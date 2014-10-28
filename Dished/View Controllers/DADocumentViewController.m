//
//  DADocumentViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADocumentViewController.h"


@interface DADocumentViewController()

@end


@implementation DADocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.documentName;
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:self.documentName ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    });
}

@end