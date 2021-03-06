//
//  DALinkedTextView.m
//  Dished
//
//  Created by Ryan Khalili on 10/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALinkedTextView.h"
#import "DATagManager.h"
#import "DACacheManager.h"

#define kLinkedTextTypeKey      @"linkedTextType"
#define kLinkedTextTypeHashtag  @"linkedTextTypeHashtag"
#define kLinkedTextTypeUsername @"linkedTextTypeUsername"
#define kLinkedTextKey          @"linkedText"
#define kDummy                  @"dummy"


@interface DALinkedTextView()

@property (copy, nonatomic) NSAttributedString *attributedString;

@end


@implementation DALinkedTextView

- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self addTapGestureRecognizer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        [self addTapGestureRecognizer];
    }
    
    return self;
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)tapDetected:(UITapGestureRecognizer *)recognizer
{
    UITextView *textView = (UITextView *)recognizer.view;
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location
                                                      inTextContainer:textView.textContainer
                             fractionOfDistanceBetweenInsertionPoints:nil];
    
    if( characterIndex < textView.textStorage.length )
    {
        if( [self.tapDelegate respondsToSelector:@selector(linkedTextView:tappedOnText:withLinkedTextType:)] )
        {
            NSString *textTapped = [self linkedTextForCharacterAtIndex:characterIndex];
            
            if( ![textTapped isEqualToString:kDummy] )
            {
                eLinkedTextType textTypeTapped = [self linkedTextTypeForCharacterAtIndex:characterIndex];
                [self.tapDelegate linkedTextView:self tappedOnText:textTapped withLinkedTextType:textTypeTapped];
            }
        }
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    NSMutableAttributedString *mutable = [attributedText mutableCopy];
    [mutable appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{ kLinkedTextKey : kDummy }]];

    [super setAttributedText:mutable];
    
    self.attributedString = mutable;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
           withAttributes:(NSDictionary *)attributes
           knownUsernames:(NSArray *)usernames
                 useCache:(BOOL)useCache
{
    NSAttributedString *cachedString = [[DACacheManager sharedManager] cachedValueForKey:attributedText.string];
    
    if( cachedString && useCache )
    {
        [super setAttributedText:cachedString];
        self.attributedString = cachedString;
        return;
    }
    
    if( !attributedText.string )
    {
        return;
    }
    
    NSMutableAttributedString *linkedText = [attributedText mutableCopy];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\B[#|@]\\S+\\b" options:0 error:nil];
    
    [regex enumerateMatchesInString:attributedText.string options:0 range:NSMakeRange( 0, [attributedText.string length] )
    usingBlock:^( NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop )
    {
        NSString *resultString = [attributedText.string substringWithRange:result.range];
        
        if( [resultString characterAtIndex:0] == '@' )
        {
            NSString *username = [resultString substringFromIndex:1];
            
            if( usernames )
            {
                if( [usernames containsObject:username] )
                {
                    [linkedText setAttributes:attributes range:result.range];
                    [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeUsername range:result.range];
                    [linkedText addAttribute:kLinkedTextKey value:username range:result.range];
                    [DATagManager addUsernameInBackground:username];
                }
            }
        }
        else if( [resultString characterAtIndex:0] == '#' )
        {
            [linkedText setAttributes:attributes range:result.range];
            [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeHashtag range:result.range];
            [linkedText addAttribute:kLinkedTextKey value:resultString range:result.range];
            [DATagManager addHashtagInBackground:resultString];
        }
    }];
    
    [linkedText appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{ kLinkedTextKey : kDummy }]];
    
    [super setAttributedText:linkedText];
    self.attributedString = linkedText;
    
    if( usernames && useCache )
    {
        [[DACacheManager sharedManager] setCachedValue:linkedText forKey:attributedText.string];
    }
}

- (eLinkedTextType)linkedTextTypeForCharacterAtIndex:(NSUInteger)characterIndex
{
    NSDictionary *attributes = [self.attributedString attributesAtIndex:characterIndex effectiveRange:nil];
    NSString *linkedTextTypeValue = [attributes objectForKey:kLinkedTextTypeKey];
    
    if( !linkedTextTypeValue )
    {
        return eLinkedTextTypePlainText;
    }
    else
    {
        if( [linkedTextTypeValue isEqualToString:kLinkedTextTypeHashtag] )
        {
            return eLinkedTextTypeHashtag;
        }
        else if( [linkedTextTypeValue isEqualToString:kLinkedTextTypeUsername] )
        {
            return eLinkedTextTypeUsername;
        }
        else
        {
            return eLinkedTextTypePlainText;
        }
    }
}

- (NSString *)linkedTextForCharacterAtIndex:(NSUInteger)characterIndex
{
    NSDictionary *wordAttributes = [self.attributedString attributesAtIndex:characterIndex effectiveRange:nil];
    NSString *word = [wordAttributes objectForKey:kLinkedTextKey];
    return word ? word : @"";
}

@end