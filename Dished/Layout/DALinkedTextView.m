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


@interface DALinkedTextView()

@property (copy, nonatomic) NSAttributedString *attributedString;

@end


@implementation DALinkedTextView

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    self.attributedString = attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText withAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter knownUsernames:(NSArray *)usernames
{
    NSAttributedString *cachedString = [[DACacheManager sharedManager] cachedValueForKey:attributedText.string];
    
    if( cachedString )
    {
        [super setAttributedText:cachedString];
        self.attributedString = cachedString;
        return;
    }
    
    NSArray *words = delimiter ? [attributedText.string componentsSeparatedByString:delimiter] : [attributedText.string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableAttributedString *linkedText = [attributedText mutableCopy];
    NSRange currentRange = NSMakeRange( 0, attributedText.string.length );
    
    NSCharacterSet *invalidCharacterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    for( NSString *word in words )
    {
        if( word.length < 2 )
        {
            continue;
        }
        
        NSRange matchRange = [attributedText.string rangeOfString:word options:0 range:currentRange];
        NSInteger newIndex = matchRange.location + matchRange.length;
        currentRange = NSMakeRange( newIndex, attributedText.string.length - newIndex );
        
        if( [word hasPrefix:@"#"] )
        {
            [linkedText setAttributes:attributes range:matchRange];
            [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeHashtag range:matchRange];
            NSString *strippedWord = [[word substringFromIndex:1] stringByTrimmingCharactersInSet:invalidCharacterSet];
            strippedWord = [NSString stringWithFormat:@"#%@", strippedWord];
            [linkedText addAttribute:kLinkedTextKey value:strippedWord range:matchRange];
            [DATagManager addHashtagInBackground:[strippedWord substringFromIndex:1]];
        }
        else if( [word hasPrefix:@"@"] )
        {
            NSString *strippedWord = [[word substringFromIndex:1] stringByTrimmingCharactersInSet:invalidCharacterSet];
            
            if( usernames )
            {
                if( [usernames containsObject:strippedWord] )
                {
                    [linkedText setAttributes:attributes range:matchRange];
                    [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeUsername range:matchRange];
                    [linkedText addAttribute:kLinkedTextKey value:strippedWord range:matchRange];
                    [DATagManager addUsernameInBackground:strippedWord];
                }
            }
        }
    }
    
    [super setAttributedText:linkedText];
    self.attributedString = linkedText;
    
    if( usernames )
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
    NSDictionary *word = [self.attributedString attributesAtIndex:characterIndex effectiveRange:nil];
    return [word objectForKey:kLinkedTextKey];
}

@end