//
//  IGGeoViewController.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGCDHGeo.h"
#import "ViewController.h"
@interface IGGeoViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) NSDictionary *fInfo;
@property (strong, nonatomic) ViewController *fPresentingViewController;
- (void) updateUI;
@end
