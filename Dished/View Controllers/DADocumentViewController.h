//
//  DADocumentViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DADocumentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (copy, nonatomic) NSString *documentName;
@property (copy, nonatomic) NSString *documentURL;

@end