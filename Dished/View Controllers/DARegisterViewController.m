//
//  DARegisterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARegisterViewController.h"
#import "DATextFieldCell.h"

static NSString *kTextFieldCellID = @"textFieldCell";
static NSString *kDateCellID      = @"dateCell";
static NSString *kPickerCellID    = @"pickerCell";
static NSString *kRegisterCellID  = @"registerCell";


@interface DARegisterViewController() <DATextFieldCellDelegate>

@property (strong, nonatomic) NSDictionary        *titleData;
@property (strong, nonatomic) NSIndexPath         *pickerIndexPath;
@property (strong, nonatomic) NSMutableDictionary *signUpData;

@end


@implementation DARegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    UINib *textCellNib = [UINib nibWithNibName:@"DATextFieldCell" bundle:nil];
    [self.tableView registerNib:textCellNib forCellReuseIdentifier:kTextFieldCellID];
    
    self.signUpData = [[NSMutableDictionary alloc] init];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 || section == 3 )
    {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( indexPath.section >= 0 && indexPath.section < 4 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellID];
        DATextFieldCell *textFieldCell = (DATextFieldCell *)cell;
        
        NSString *placeholder = self.titleData[@(indexPath.section)][indexPath.row];
        textFieldCell.textField.placeholder = placeholder;
        textFieldCell.delegate = self;
        
        if( indexPath.section == 1 || indexPath.section == 2 )
        {
            textFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        
        if( indexPath.section == 3 )
        {
            textFieldCell.textField.secureTextEntry = YES;
        }
        
        if( indexPath.section == 3 && indexPath.row == 1 )
        {
            textFieldCell.textField.returnKeyType = UIReturnKeyDone;
        }
        else
        {
            textFieldCell.textField.returnKeyType = UIReturnKeyNext;
        }
    }
    else if( indexPath.section == 4 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kDateCellID];
        
        cell.textLabel.text = self.titleData[@(indexPath.section)][indexPath.row];
    }
    else if( indexPath.section == 5 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kRegisterCellID];
        
        cell.textLabel.text = self.titleData[@(indexPath.section)][indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5 )
    {
        return 54;
    }
    
    return self.tableView.rowHeight;
}

- (BOOL)hasInlinePicker
{
    return ( self.pickerIndexPath != nil );
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ( [self hasInlinePicker] && self.pickerIndexPath.row == indexPath.row );
}

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasPicker = NO;
    
    NSInteger targetedRow = indexPath.row + 1;
    NSIndexPath *targetedPath = [NSIndexPath indexPathForRow:targetedRow inSection:0];
    
    UITableViewCell *checkPickerCell = [self.tableView cellForRowAtIndexPath:targetedPath];
    
    hasPicker = ( checkPickerCell.reuseIdentifier == kPickerCellID );
    
    return hasPicker;
}

- (void)textField:(UITextField *)textField didBeginEditingInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if( indexPath.section == 1 )
    {
        if( [textField.text length] == 0 )
        {
            textField.text = @"@";
        }
    }
}

- (void)textField:(UITextField *)textField didEndEditingInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
    
    [self.signUpData setObject:textField.text forKey:key];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string inCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if( indexPath.section == 1 )
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if( [newString length] == 0 )
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldReturnInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
        else
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
    }
    else if( indexPath.section == 1 )
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        [cell.textField becomeFirstResponder];
    }
    else if( indexPath.section == 2 )
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        [cell.textField becomeFirstResponder];
    }
    else if( indexPath.section == 3 )
    {
        if( indexPath.row == 0 )
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
        else
        {
            [self.view endEditing:YES];
            return YES;
        }
    }
    
    return NO;
}

- (NSDictionary *)titleData
{
    if( !_titleData )
    {
        _titleData = @{ @0 : @[ @"First Name", @"Last Name" ], @1 : @[ @"Username" ], @2 : @[ @"Email" ], @3 : @[ @"Password", @"Confirm Password" ], @4 : @[ @"Date of Birth" ], @5 : @[ @"Register" ] };
    }
    
    return _titleData;
}

@end
