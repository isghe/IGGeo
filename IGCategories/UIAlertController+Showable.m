//
//  UIAlertController+Showable.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 15/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "UIAlertController+Showable.h"

@implementation UIAlertController (Showable)
- (void)show{
    [self presentAnimated:YES completion:nil];
}

- (void)presentAnimated:(BOOL)animated
             completion:(void (^)(void))completion{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC != nil) {
        [self presentFromController:rootVC animated:animated completion:completion];
    }
}

- (void)presentFromController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^)(void))completion{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visibleVC = ((UINavigationController *)viewController).visibleViewController;
        [self presentFromController:visibleVC animated:animated completion:completion];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = ((UITabBarController *)viewController).selectedViewController;
        [self presentFromController:selectedVC animated:animated completion:completion];
    } else {
        [viewController presentViewController:self animated:animated completion:completion];
    }
}

@end
