//
//  IGCDConnectionGeo.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 21/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGCDConnection, IGCDHGeo;

@interface IGCDConnectionGeo : NSManagedObject

@property (nonatomic, retain) IGCDHGeo *geo_ref;
@property (nonatomic, retain) IGCDConnection *connection_ref;

@end
