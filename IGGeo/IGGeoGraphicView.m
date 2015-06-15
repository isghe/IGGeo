//
//  IGGeoGraphicView.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 15/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGGeoGraphicView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IGGeoGraphicView

#if 0
#ifdef IG_DIM_OF_ARRAY
#error "IG_DIM_OF_ARRAY already defined"
#endif

#define IG_DIM_OF_ARRAY(theArray) (sizeof(theArray)/sizeof(theArray [0]))

static void IGDrawSegments (CGContextRef theContext, const CGPoint thePoints [][2], const int theLength){
    for (int i = 0; i < theLength; ++i){
        CGContextMoveToPoint(theContext, thePoints [i][0].x, thePoints [i][0].y);
        CGContextAddLineToPoint(theContext, thePoints [i][1].x, thePoints [i][1].y);
    }
}

- (void) drawMonoscopioInContext: (CGContextRef) theContext inRect: (CGRect) theRect{
    const CGRect aInsetRect = CGRectInset(theRect, 1.5, 1.5);
    CGContextStrokeRect(theContext, aInsetRect);
    
    typedef CGPoint tSegment[2];
    const tSegment aSegments []={
        {   aInsetRect.origin,
            CGPointMake(aInsetRect.origin.x + aInsetRect.size.width, aInsetRect.origin.y + aInsetRect.size.height)
        },
        {   CGPointMake(aInsetRect.origin.x, aInsetRect.origin.y + aInsetRect.size.height),
            CGPointMake(aInsetRect.origin.x + aInsetRect.size.width, aInsetRect.origin.y)
        }
    };
    IGDrawSegments (theContext, aSegments, IG_DIM_OF_ARRAY (aSegments));
    
    CGContextStrokePath(theContext);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    [self drawMonoscopioInContext:context inRect:rect];
}
*/

#pragma mark - CALayerDelegate
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    [self drawMonoscopioInContext:context inRect:layer.frame];
    CGContextRestoreGState(context);
}
#endif
@end
