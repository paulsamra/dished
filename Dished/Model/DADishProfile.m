//
//  DADishProfile.m
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishProfile.h"

NSString *const kDAPGradeA   = @"As";
NSString *const kDAPGradeB   = @"Bs";
NSString *const kDAPGradeC   = @"Cs";
NSString *const kDAPGradeDF  = @"Ds & Fs";
NSString *const kDAPGradeAll = @"All Grades";


@interface DADishProfile()

@property (strong, nonatomic) NSMutableDictionary *mutableReviews;

@end


@implementation DADishProfile

+ (DADishProfile *)profileWithData:(id)data
{
    return [[DADishProfile alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        _name            = nilOrJSONObjectForKey( data, kNameKey );
        _desc            = nilOrJSONObjectForKey( data, @"desc" );
        _price           = nilOrJSONObjectForKey( data, kPriceKey );
        _type            = nilOrJSONObjectForKey( data, kTypeKey );
        _loc_name        = nilOrJSONObjectForKey( data, kLocationNameKey );
        _grade           = nilOrJSONObjectForKey( data, kGradeKey );
        _images          = nilOrJSONObjectForKey( data, kImagesKey );
        
        NSDictionary *grades = nilOrJSONObjectForKey( data, @"num_grades" );
        _aGrades  = [grades[@"A"]  integerValue];
        _bGrades  = [grades[@"B"]  integerValue];
        _cGrades  = [grades[@"C"]  integerValue];
        _dfGrades = [grades[@"DF"] integerValue];
        
        _dish_id         = [nilOrJSONObjectForKey( data, kIDKey )         integerValue];
        _loc_id          = [nilOrJSONObjectForKey( data, kLocationIDKey ) integerValue];
        _num_yums        = [data[@"num_yums"]   integerValue];
        _num_images      = [data[@"num_images"] integerValue];
        
        _additional_info = [data[@"additional_info"] boolValue];
        
        NSArray *reviews = nilOrJSONObjectForKey( data, kReviewsKey );
        if( reviews )
        {
            NSMutableArray *aReviews   = [NSMutableArray array];
            NSMutableArray *bReviews   = [NSMutableArray array];
            NSMutableArray *cReviews   = [NSMutableArray array];
            NSMutableArray *dfReviews  = [NSMutableArray array];
            NSMutableArray *allReviews = [NSMutableArray array];
            
            NSMutableDictionary *reviewDict = [NSMutableDictionary dictionary];
            
            for( NSDictionary *review in reviews )
            {
                DAReview *newReview = [[DAReview alloc] initWithData:review];
                [allReviews addObject:newReview];
                
                switch( [[newReview.grade lowercaseString] characterAtIndex:0] )
                {
                    case 'a': [aReviews addObject:newReview]; break;
                    case 'b': [bReviews addObject:newReview]; break;
                    case 'c': [cReviews addObject:newReview]; break;
                    case 'd':
                    case 'f':
                        [dfReviews addObject:newReview];
                        break;
                }
            }
            
            reviewDict[kDAPGradeA]   = aReviews;
            reviewDict[kDAPGradeB]   = bReviews;
            reviewDict[kDAPGradeC]   = cReviews;
            reviewDict[kDAPGradeDF]  = dfReviews;
            reviewDict[kDAPGradeAll] = allReviews;
            
            _mutableReviews = reviewDict;
        }
    }
    
    return self;
}

- (NSDictionary *)reviews
{
    return self.mutableReviews;
}

- (void)setReviewData:(NSArray *)data forGradeKey:(NSString *)key
{
    NSMutableArray *newReviews = [NSMutableArray array];
    
    for( NSDictionary *review in data )
    {
        DAReview *newReview = [[DAReview alloc] initWithData:review];
        [newReviews addObject:newReview];
    }
    
    self.mutableReviews[key] = newReviews;
}

- (void)addReviewData:(NSArray *)data forGradeKey:(NSString *)key
{
    NSMutableArray *newReviews = [NSMutableArray array];
    
    for( NSDictionary *review in data )
    {
        DAReview *newReview = [[DAReview alloc] initWithData:review];
        [newReviews addObject:newReview];
    }
    
    NSArray *currentReviews = self.mutableReviews[key];
    self.mutableReviews[key] = [currentReviews arrayByAddingObjectsFromArray:newReviews];
}

@end