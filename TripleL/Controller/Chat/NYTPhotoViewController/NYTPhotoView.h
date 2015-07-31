//
//  NYTPhotoView.h
//  Pocket Cryptology
//
//  Created by h1r0 on 15/4/8.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//


#import "NYTPhoto.h"

@interface NYTPhotoView : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *path;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;


@end
