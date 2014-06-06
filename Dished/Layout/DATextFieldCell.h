//
//  TextFieldUITableViewCell.h
//  GoRunMU
//
//  Created by Ryan Khalili on 1/17/14.
//  Copyright (c) 2014 Ryan Khalili. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DATextFieldCellDelegate <NSObject>

@optional
- (void)textField:(UITextField *)textField didEndEditingInCell:(UITableViewCell *)cell;
- (void)textField:(UITextField *)textField didBeginEditingInCell:(UITableViewCell *)cell;
- (BOOL)textField:(UITextField *)textField shouldReturnInCell:(UITableViewCell *)cell;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string inCell:(UITableViewCell *)cell;

@end


@interface DATextFieldCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) id<DATextFieldCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end