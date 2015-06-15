//
//  ViewController.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 11/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "IGCDHGeo.h"
#import "IGCDCircle.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
// @property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
- (void) IGHandleError: (NSError *) theError;

#pragma mark - geo
- (IGCDCircle *) geoInsertCircle: (IGCDHGeo *) theGeo withOrigin: (CGPoint) theOrigin andRadious: (CGFloat) theRadious;
- (NSArray *) geoCircles: (IGCDHGeo *) theGeo;
- (void) geoDeleteCircle: (IGCDCircle *) theCircle;
- (void) geoSave;
- (void) geoHandleFetch: (NSArray *) theArray inGeo: (IGCDHGeo *) theGeo;
- (NSArray *) geoConnections: (IGCDCircle *) theCircle;
- (NSUInteger) geoConnectionsCountInGeo: (IGCDHGeo *) theGeo;
- (NSArray *) geoConnectionsInGeo: (IGCDHGeo *) theGeo;

@end
