//
//  DAManagedUserSuggestion.h
//  Dished
//
//  Created by Ryan Khalili on 4/15/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DAManagedUserSuggestion : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * img_thumb;
@property (nonatomic, retain) id reviews;
@property (nonatomic, retain) NSString * user_type;
@property (nonatomic, retain) NSString * username;

@end
