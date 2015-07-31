//
//  RegisterViewController.h
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MyServer.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic)UITextField *userNameField;
@property (strong, nonatomic)UITextField *nickNameField;
@property (strong, nonatomic)UITextField *pswordField;

@end
