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
            eLinkedTextType textTypeTapped = [self linkedTextTypeForCharacterAtIndex:characterIndex];
            [self.tapDelegate linkedTextView:self tappedOnText:textTapped withLinkedTextType:textTypeTapped];
        }
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    self.attributedString = attributedText;
}

//- (void)setAttributedText:(NSAttributedString *)attributedText withAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter knownUsernames:(NSArray *)usernames
//{
//    NSAttributedString *cachedString = [[DACacheManager sharedManager] cachedValueForKey:attributedText.string];
//    
//    if( cachedString )
//    {
//        [super setAttributedText:cachedString];
//        self.attributedString = cachedString;
//        return;
//    }
//    
//    NSArray *words = delimiter ? [attributedText.string componentsSeparatedByString:delimiter] : [attributedText.string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSMutableAttributedString *linkedText = [attributedText mutableCopy];
//    NSRange currentRange = NSMakeRange( 0, attributedText.string.length );
//    
//    NSCharacterSet *invalidCharacterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
//
//    for( NSString *word in words )
//    {
//        if( word.length < 2 )
//        {
//            continue;
//        }
//        
//        NSRange matchRange = [attributedText.string rangeOfString:word options:0 range:currentRange];
//        NSInteger newIndex = matchRange.location + matchRange.length;
//        currentRange = NSMakeRange( newIndex, attributedText.string.length - newIndex );
//        
//        if( [word hasPrefix:@"#"] )
//        {
//            [linkedText setAttributes:attributes range:matchRange];
//            [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeHashtag range:matchRange];
//            NSString *strippedWord = [[word substringFromIndex:1] stringByTrimmingCharactersInSet:invalidCharacterSet];
//            strippedWord = [NSString stringWithFormat:@"#%@", strippedWord];
//            [linkedText addAttribute:kLinkedTextKey value:strippedWord range:matchRange];
//            [DATagManager addHashtagInBackground:[strippedWord substringFromIndex:1]];
//        }
//        else if( [word hasPrefix:@"@"] )
//        {
//            NSString *strippedWord = [[word substringFromIndex:1] stringByTrimmingCharactersInSet:invalidCharacterSet];
//            
//            if( usernames )
//            {
//                if( [usernames containsObject:strippedWord] )
//                {
//                    [linkedText setAttributes:attributes range:matchRange];
//                    [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeUsername range:matchRange];
//                    [linkedText addAttribute:kLinkedTextKey value:strippedWord range:matchRange];
//                    [DATagManager addUsernameInBackground:strippedWord];
//                }
//            }
//        }
//    }
//    
//    [super setAttributedText:linkedText];
//    self.attributedString = linkedText;
//    
//    if( usernames )
//    {
//        [[DACacheManager sharedManager] setCachedValue:linkedText forKey:attributedText.string];
//    }
//}

- (void)setAttributedText:(NSAttributedString *)attributedText withAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter knownUsernames:(NSArray *)usernames
{
    NSAttributedString *cachedString = [[DACacheManager sharedManager] cachedValueForKey:attributedText.string];
    
    if( cachedString )
    {
        [super setAttributedText:cachedString];
        self.attributedString = cachedString;
        return;
    }
    
    NSString *nextWord = [NSString string];
    NSMutableAttributedString *linkedText = [attributedText mutableCopy];
    
    NSScanner *scanner = [NSScanner scannerWithString:attributedText.string];
    scanner.charactersToBeSkipped = nil;
    
    NSCharacterSet *symbols = [NSCharacterSet characterSetWithCharactersInString:@"#@"];
    NSCharacterSet *alphanumericCharacters = [NSCharacterSet alphanumericCharacterSet];
    
    [scanner scanUpToCharactersFromSet:symbols intoString:nil];
    
    NSUInteger startLocation = 0;
    NSUInteger length = 0;
    
    while( !scanner.isAtEnd )
    {
        char symbol = [scanner.string characterAtIndex:scanner.scanLocation];
        
        if( symbol == '@' )
        {
            startLocation = scanner.scanLocation++;
            
            if( [scanner scanCharactersFromSet:alphanumericCharacters intoString:&nextWord] )
            {
                length = scanner.scanLocation - startLocation;
                
                if( usernames )
                {
                    if( [usernames containsObject:nextWord] )
                    {
                        NSRange matchRange = NSMakeRange( startLocation, length );
                        [linkedText setAttributes:attributes range:matchRange];
                        [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeUsername range:matchRange];
                        [linkedText addAttribute:kLinkedTextKey value:nextWord range:matchRange];
                        [DATagManager addUsernameInBackground:nextWord];
                    }
                }
            }
        }
        else if( symbol == '#' )
        {
            startLocation = scanner.scanLocation++;
            
            if( [scanner scanCharactersFromSet:alphanumericCharacters intoString:&nextWord] )
            {
                length = scanner.scanLocation - startLocation;
                
                if( ![scanner isAtEnd] )
                {
                    char nextCharacter = [scanner.string characterAtIndex:scanner.scanLocation];
                    
                    if( [symbols characterIsMember:nextCharacter] )
                    {
                        [scanner scanUpToCharactersFromSet:symbols intoString:nil];
                        continue;
                    }
                }
                
                NSRange matchRange = NSMakeRange( startLocation, length );
                
                [linkedText setAttributes:attributes range:matchRange];
                [linkedText addAttribute:kLinkedTextTypeKey value:kLinkedTextTypeHashtag range:matchRange];
                NSString *hashtag = [NSString stringWithFormat:@"#%@", nextWord];
                [linkedText addAttribute:kLinkedTextKey value:hashtag range:matchRange];
                [DATagManager addHashtagInBackground:nextWord];
            }
        }
        
        [scanner scanUpToCharactersFromSet:symbols intoString:nil];
    }
    
    [linkedText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
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