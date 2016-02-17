//
//  ChangePasswordViewController.m
//  ParlorMe
//
//  Created by sakshi on 15/12/15.
//  Copyright © 2015 dreamorbit. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "WebserviceViewController.h"
#import "Constants.h"
#import "Utility.h"

@interface ChangePasswordViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@end
/*<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>*/
@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Adding bottom border to textfield
    [self ChangeTextfieldBorder:self.passwordTextField];
    [self ChangeTextfieldBorder:self.confirmPasswordTextField];
    
    // To change colour of placeholder text
    [self.passwordTextField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.confirmPasswordTextField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark- Tap Gesture
-(IBAction)tapped
{
    [self.view endEditing:YES];
}

#pragma mark - Close Button Action

- (IBAction)buttonAction:(UIButton *)sender
{
    if (sender.tag == 1) {//close button selected
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (sender.tag == 2) {//change password button selected
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isToShowMessage = YES;
        NSString *message = @"";
        if ([[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            message = @"Please enter the new password";
            [self.passwordTextField becomeFirstResponder];
        }
        else if ([[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 6) {
            message = @"Password should have minimum 6 characters";
            [self.passwordTextField becomeFirstResponder];
        }
        else if ([[userDefaults objectForKey:@"Password"] isEqualToString:self.passwordTextField.text]) {
            self.passwordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
            message = @"Password cannot be same as your current one";
            [self.passwordTextField becomeFirstResponder];
        }
        else if ([[self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            message = @"Please confirm the password";
            [self.confirmPasswordTextField becomeFirstResponder];
        }
        else if (![[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
            message = @"Passwords you typed do not match";
            [self.confirmPasswordTextField becomeFirstResponder];
        }
        else
            isToShowMessage = NO;
        
        if (isToShowMessage) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        else {
            //send back password to profile page..
            if ([self.delegate respondsToSelector:@selector(getStylistPassword:)]) {
                [self.delegate getStylistPassword:self.passwordTextField.text];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Textfield Bottom Border
// Set Bottom Border for Textfields
- (void)ChangeTextfieldBorder: (UITextField*) txtfld
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, txtfld.frame.size.height - 1, txtfld.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [txtfld.layer addSublayer:bottomBorder];
}

#pragma mark - Textfield Delegates
// On tap of Next button on Keyboard, Textfield focus shoule move on next item
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
