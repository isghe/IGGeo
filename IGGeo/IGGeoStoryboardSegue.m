//
//  IGGeoStoryboardSegue.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 14/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGGeoStoryboardSegue.h"
#import "IGGeoViewController.h"
#import "IGGeoConfiguration.h"

@implementation IGGeoStoryboardSegue

- (void)perform{
    NSParameterAssert([self.sourceViewController isKindOfClass:[ViewController class]]);
    ViewController *source = self.sourceViewController;
    IGGeoViewController *destination = self.destinationViewController;
    destination.fPresentingViewController = source;
    UIWindow *window = source.view.window;
    
    CATransition *transition = [CATransition animation];
    [transition setDuration:kIGAnimationTransitionDuration];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromRight];
    [transition setFillMode:kCAFillModeForwards];
    [transition setRemovedOnCompletion:YES];
    
    
    [window.layer addAnimation:transition forKey:kCATransition];
    [window setRootViewController:destination];
}

@end
