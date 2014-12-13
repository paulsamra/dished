//
//  DAManagedComment+Utility.h
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAManagedComment.h"


@interface DAManagedComment (Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary;
- (NSAttributedString *)attributedCommentStringWithFont:(UIFont *)font;
+ (NSString *)entityName;

@end