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


@interface DALinkedTextView : UITextView

- (eLinkedTextType)linkedTextTypeForCharacterAtIndex:(NSUInteger)characterIndex;
- (NSString *)linkedTextForCharacterAtIndex:(NSUInteger)characterIndex;

@end