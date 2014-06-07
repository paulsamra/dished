//
//  TextFieldUITableViewCell.m
//  GoRunMU
//
//  Created by Ryan Khalili on 1/17/14.
//  Copyright (c) 2014 Ryan Khalili. All rights reserved.
//

#import "DATextFieldCell.h"

@implementation DATextFieldCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( [self.delegate respondsToSelector:@selector(textField:didEndEditingInCell:)] )
    {
        [self.delegate textField:textField didEndEditingInCell:self];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( [self.delegate respondsToSelector:@selector(textField:didBeginEditingInCell:)] )
    {
        [self.delegate textField:textField didBeginEditingInCell:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;
    
    if( [self.delegate respondsToSelector:@selector(textField:shouldReturnInCell:)] )
    {
        shouldReturn = [self.delegate textField:textField shouldReturnInCell:self];
    }
    
    return shouldReturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    if( [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:inCell:)] )
    {
        shouldChange = [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string inCell:self];
    }
    
    return shouldChange;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end