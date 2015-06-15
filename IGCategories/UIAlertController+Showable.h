//
//  UIAlertController+Showable.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 15/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Showable)
- (void)show;
- (void)presentAnimated:(BOOL)animated
             completion:(void (^)(void))completion;
- (void)presentFromController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^)(void))completion;
@end
