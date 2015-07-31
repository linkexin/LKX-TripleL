//
//  gameProtocol.h
//  TripleL
//
//  Created by charles on 5/24/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol gameProtocol <NSObject>

-(void)gameSucceefully: (id)viewController;
-(void)gameOver: (id)viewController;

@end
