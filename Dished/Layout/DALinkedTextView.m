//
//  DALinkedTextView.m
//  Dished
//
//  Created by Ryan Khalili on 10/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALinkedTextView.h"

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
    NSAttributedString *linkedAttributedText = [self addLinkedTextAttributesToAttributedText:attributedText withDelimiter:nil];
    
    [super setAttributedText:linkedAttributedText];
    
    self.attributedString = linkedAttributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText withDelimiter:(NSString *)delimiter
{
    NSAttributedString *linkedAttributedText = [self addLinkedTextAttributesToAttributedText:attributedText withDelimiter:delimiter];
    
    [super setAttributedText:linkedAttributedText];
    
    self.attributedString = linkedAttributedText;
}

- (NSAttributedString *)addLinkedTextAttributesToAttributedText:(NSAttributedString *)attributedText withDelimiter:(NSString *)delimiter
{
    NSArray *words = delimiter ? [attributedText.string componentsSeparatedByString:delimiter] : [attributedText.string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableAttributedString *linkedText = [attributedText mutableCopy];
    NSRange currentRange = NSMakeRange( 0, attributedText.string.length );
    
    for( NSString *word in words )
    {
        if( word.length == 0 )
        {
            continue;
        }
        
        NSRange matchRange = [attributedText.string rangeOfString:word options:0 range:currentRange];
        NSInteger newIndex = matchRange.location + matchRange.length;
        currentRange = NSMakeRange( newIndex, attributedText.string.length - newIndex );
        
        if( [word hasPrefix:@"#"] )
        {
            [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeHashtag range:matchRange];
            [linkedText addAttribute:kLinkedTextKey value:word range:matchRange];
        }
        else if( [word hasPrefix:@"@"] )
        {
            [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeUsername range:matchRange];
            [linkedText addAttribute:kLinkedTextKey value:word range:matchRange];
        }
    }
    
    return linkedText;
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