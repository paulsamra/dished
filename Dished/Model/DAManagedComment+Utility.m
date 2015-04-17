//
//  DAManagedComment+Utility.m
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAManagedComment+Utility.h"


@implementation DAManagedComment (Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( dictionary, kCreatedKey ) doubleValue];
    self.created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    self.creator_type      = nilOrJSONObjectForKey( dictionary, @"creator_type" );
    self.creator_username  = nilOrJSONObjectForKey( dictionary, @"creator_username" );
    self.img_thumb         = nilOrJSONObjectForKey( dictionary, @"img_thumb" );
    self.comment           = nilOrJSONObjectForKey( dictionary, kCommentKey );
    
    self.creator_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"creator_id" )];
    self.comment_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, kIDKey )];
}

- (NSAttributedString *)attributedCommentStringWithFont:(UIFont *)font
{
    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    NSString *usernameString = [NSString stringWithFormat:@"@%@", self.creator_username];
    NSMutableAttributedString *finalString = [[[NSAttributedString alloc] initWithString:usernameString attributes:textAttributes] mutableCopy];
    
    if( [self.creator_type isEqualToString:kInfluencerUserType] )
    {
        [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:[[DAInfluencerTextAttachment alloc] init]];
        [finalString appendAttributedString:influencerIconString];
    }
    
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:self.comment attributes:textAttributes];
    [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [finalString appendAttributedString:commentString];
    
    return finalString;
}

+ (NSString *)entityName
{
    return NSStringFromClass( [self class] );
}

@end