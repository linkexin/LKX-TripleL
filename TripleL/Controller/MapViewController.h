//
//  MapViewController.h
//  toFace
//
//  Created by charles on 4/13/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CusAnnotationView.h"
#import <CoreMotion/CoreMotion.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import "FigurePuzzleViewController.h"

@interface MapViewController : UIViewController <MAMapViewDelegate, CLLocationManagerDelegate, CusAnnotationDelegate>
{
    MAMapView *_mapView;
    CMMotionManager *_shakeManager;
    MAPointAnnotation *_userPointAnnotation;
}
@property (nonatomic, strong)CLLocationManager *locManager;


@end
