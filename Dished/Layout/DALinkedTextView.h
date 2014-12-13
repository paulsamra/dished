//
//  DALinkedTextView.h
//  Dished
//
//  Created by Ryan Khalili on 10/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    eLinkedTextTypeHashtag,
    eLinkedTextTypeUsername,
    eLinkedTextTypePlainText
} eLinkedTextType;


@class DALinkedTextView;

@protocol DALinkedTextViewDelegate <NSObject>

@optional
- (void)linkedTextView:(DALinkedTextView *)textView tappedOnText:(NSString *)text withLinkedTextType:(eLinkedTextType)textType;

@end


@interface DALinkedTextView : UITextView

@property (weak, nonatomic) id<DALinkedTextViewDelegate> tapDelegate;

- (void)setAttributedText:(NSAttributedString *)attributedText withAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter knownUsernames:(NSArray *)usernames;
- (eLinkedTextType)linkedTextTypeForCharacterAtIndex:(NSUInteger)characterIndex;
- (NSString *)linkedTextForCharacterAtIndex:(NSUInteger)characterIndex;

@end