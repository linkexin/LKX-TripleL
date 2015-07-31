//
//  ImageUploadViewController.h
//  toFace
//
//  Created by charles on 4/12/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageUploadViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic)UIImageView *bgView;
@property (strong, nonatomic)UIVisualEffectView *effectview;
@property(nonatomic, strong) NSData *fileData;

@property (strong, nonatomic)UIButton *selectIconButton;
@property (strong, nonatomic)UIImageView *profilePhoto;
@property (strong, nonatomic)UIButton *selectGenderButton;
@property (strong, nonatomic)UIButton *selectBirthButton;
@property (strong, nonatomic)UIButton *completeButton;
@property (strong, nonatomic)UILabel *errorInfoLabel;

@property (strong, nonatomic)UIDatePicker *datePicker;

-(void)getinfowith: (NSString *)username nick:(NSString *)nickname psword:(NSString *)psword;

@end
