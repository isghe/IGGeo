//
//  IGNodeViewController.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 14/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "IGGeoViewController.h"

@interface IGNodeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) ViewController *fRootViewController;
@property (strong, nonatomic) NSDictionary *fInfo;
@property (strong, nonatomic) IGGeoViewController *fGeoViewController;
@end
