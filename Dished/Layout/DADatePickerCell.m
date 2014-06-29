//
//  DatePickerCell.m
//  Bulletin
//
//  Created by Ryan Khalili on 3/8/14.
//  Copyright (c) 2014 Burlington Code Factory. All rights reserved.
//

#import "DADatePickerCell.h"

@implementation DADatePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        [self setupDatePicker];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if( self )
    {
        [self setupDatePicker];
    }
    
    return self;
}

- (void)setupDatePicker
{
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, -25, 320, 162)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *defaultDateComponents = [[NSDateComponents alloc] init];
    [defaultDateComponents setYear:1990];
    [defaultDateComponents setDay:15];
    [defaultDateComponents setMonth:6];
    self.datePicker.date = [[NSCalendar currentCalendar] dateFromComponents:defaultDateComponents];
    self.datePicker.maximumDate = currentDate;
    
    [self.contentView addSubview:self.datePicker];
}

@end