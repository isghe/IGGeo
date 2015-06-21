//
//  IGGeoViewController.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGGeoViewController.h"
#import "IGGeoConfiguration.h"
#import "IGNodeViewController.h"
#import "IGGeoGraphicView.h"
#import "IGCDPoint.h"
#import "IGCDConnection.h"

@interface IGGeoViewController (){
    CGRect fBoundingBox;
}
@property (weak, nonatomic) IBOutlet UILabel *fHeader;
@property (weak, nonatomic) IBOutlet UIView *fButtonFetch;
@property (weak, nonatomic) IBOutlet UITextField *fTextFieldFetchURL;
@property (strong, nonatomic) IGNodeViewController *fNodeViewController;
@property (weak, nonatomic) IBOutlet UIScrollView *fScrollerView;
@property (strong, nonatomic) CALayer * fLayer;
@property (strong, nonatomic) UIView * fGraph;
@property (readonly, strong, nonatomic) NSArray * fConnections;
@property (readonly, strong, nonatomic) NSArray * fCircles;
@end

@implementation IGGeoViewController

- (void) updateUI{
    [self updateHeader];
    [self updateGraph];
}

- (void) updateUI_async{
    typeof(self) __block bSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [bSelf updateUI];
        });
    });
}

+ (id) executeBlock: (id (^)(void)) block withTag: (NSString *) theTag{
    const CFAbsoluteTime aBegin = CFAbsoluteTimeGetCurrent ();
    id ret = block ();
    const CFAbsoluteTime aDeltaInside = CFAbsoluteTimeGetCurrent () - aBegin;
    NSLog (@"%s - %@ - aDelta: %@", __PRETTY_FUNCTION__, theTag, @(aDeltaInside * 1000).stringValue);
    return ret;
}

- (void) updateHeaderPrivate{
    IGCDHGeo * aGeo = self.fInfo [@"geo"];
    NSIndexPath * aIndexPath = self.fInfo [@"index_path"];
    self->_fCircles = [self.fPresentingViewController geoCircles:aGeo];
    const NSUInteger aCirclesCount = self->_fCircles.count;
    self->_fConnections = [self.fPresentingViewController geoConnectionsInGeo:aGeo];
    const NSUInteger aConnectionsCount = self.fConnections.count;
    self.fHeader.text = [NSString stringWithFormat: @"%@ - %@; Circles: %@, Connections: %@", @(aIndexPath.row +1), aGeo.dateTimeInsert.description, @(aCirclesCount), @(aConnectionsCount)];
}

- (void)updateHeader {
    typeof(self) __block bSelf = self;
    [[self class] executeBlock:^{
        id ret = nil;
        [bSelf updateHeaderPrivate];
        return ret;
    } withTag:@"updateHeader"];
}

static BOOL IGIsValidBoundingBox (const CGRect theRect){
    return !CGRectIsEmpty(theRect) && (0.0 != theRect.size.width) &&(0.0 != theRect.size.height);
}

- (void) updateGraph{
    // graph
    NSArray * aCircles = self.fCircles;
    const CGRect aBoundingBox = CalculateBoundingBox (aCircles);
    self->fBoundingBox = aBoundingBox;
    NSLog (@"%s - aBoundingBox: %@; isValid: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(aBoundingBox), @(IGIsValidBoundingBox(aBoundingBox)));
    /*
     bX/bY = fX/fY
     fY = fX*bY/bX
     */
    if (IGIsValidBoundingBox(aBoundingBox)){
        if (nil != self.fGraph){
            NSParameterAssert (nil != self.fLayer);
            self.fLayer.delegate = nil;
            [self.fGraph removeFromSuperview];
            self.fGraph = nil;
            self.fLayer = nil;
        }
        const CGFloat aRatio = aBoundingBox.size.width/aBoundingBox.size.height;
        const CGFloat aFactorWidth = 1; ///(aView.frame.size.width/aBoundingBox.size.width);
        const CGFloat aFactorHeight = 1; ///(aView.frame.size.height/aBoundingBox.size.height);

        const CGSize aViewFrameSize = CGSizeMake (self.fScrollerView.frame.size.width/aFactorWidth, self.fScrollerView.frame.size.width/(aRatio*aFactorHeight));
        const CGFloat aYOffset = (self.fScrollerView.frame.size.height - aViewFrameSize.height)/2.0;
        IGGeoGraphicView * aView = [[IGGeoGraphicView alloc] initWithFrame:CGRectMake(0, aYOffset, aViewFrameSize.width, aViewFrameSize.height)];
        self.fGraph = aView;
        // IGGeoGraphicView * aView = [[IGGeoGraphicView alloc] initWithFrame:CGRectMake(0, 0, aBoundingBox.size.width, aBoundingBox.size.height)];
        // CGAffineTransform aScaleTransform = CGAffineTransformMakeScale(aFactorWidth, aFactorHeight);

        aView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.75 alpha:1];
        aView.fRootViewController = self.fPresentingViewController;
        // aView.layer.transform = CATransform3DMakeAffineTransform (aScaleTransform);

        CALayer * aLayer = [[CALayer alloc] init];
        self.fLayer = aLayer;
        aLayer.frame = CGRectMake(0, 0, aView.frame.size.width/aFactorWidth, aView.frame.size.height/aFactorHeight);
        NSLog (@"%s - aFactorWidth: %@; aFactorHeight: %@", __PRETTY_FUNCTION__, @(aFactorWidth), @(aFactorHeight));
        NSLog (@"%s - aView.frame: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(aView.frame));
        NSLog (@"%s - aLayer.frame: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(aLayer.frame));
        aLayer.masksToBounds = YES;
        aLayer.delegate = self;
        [aView.layer addSublayer:aLayer];
        [self.fScrollerView addSubview:aView];
        self.fScrollerView.contentSize = CGSizeMake ((aView.frame.size.width + aView.frame.origin.x), (aView.frame.size.height + aView.frame.origin.y));
        // self.fScrollerView.zoomScale = 100.1;
        [aLayer setNeedsDisplay];
    }
}

static CGRect CalculateBoundingBox (NSArray * theCircles){
    NSCParameterAssert(nil != theCircles);

    CGFloat aMinX = CGFLOAT_MAX;
    CGFloat aMaxX = CGFLOAT_MIN;
    CGFloat aMinY = CGFLOAT_MAX;
    CGFloat aMaxY = CGFLOAT_MIN;
    for (IGCDCircle * aCircle in theCircles){
        const CGFloat aLocalMinX = aCircle.circle_pt_point.x.floatValue - aCircle.radius.floatValue;
        if (aLocalMinX < aMinX){
            aMinX = aLocalMinX;
        }

        const CGFloat aLocalMinY = aCircle.circle_pt_point.y.floatValue - aCircle.radius.floatValue;
        if (aLocalMinY < aMinY){
            aMinY = aLocalMinY;
        }

        const CGFloat aLocalMaxX = aCircle.circle_pt_point.x.floatValue + aCircle.radius.floatValue;
        if (aLocalMaxX > aMaxX){
            aMaxX = aLocalMaxX;
        }

        const CGFloat aLocalMaxY = aCircle.circle_pt_point.y.floatValue + aCircle.radius.floatValue;
        if (aLocalMaxY > aMaxY){
            aMaxY = aLocalMaxY;
        }
    }
    return CGRectMake(aMinX, aMinY, aMaxX - aMinX, aMaxY - aMinY);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fHeader.text = @"loading...";
    [self updateUI_async];
}
/*
-(void)viewWillAppear:(BOOL)animated
{
    if (self.fLayer) {
        self.fLayer.delegate = nil;
    }
    self.fLayer = nil;
}
 */
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.fLayer) {
        self.fLayer.delegate = nil;
    }
    self.fLayer = nil;
}
#pragma mark - CALayerDelegate

#ifdef IG_DIM_OF_ARRAY
#error "IG_DIM_OF_ARRAY already defined"
#endif

#define IG_DIM_OF_ARRAY(theArray) (sizeof(theArray)/sizeof(theArray [0]))

static void IGDrawSegment (CGContextRef theContext, const CGPoint theSegment [2]){
    CGContextMoveToPoint(theContext, theSegment [0].x, theSegment [0].y);
    CGContextAddLineToPoint(theContext, theSegment [1].x, theSegment [1].y);
}

static void IGDrawSegments (CGContextRef theContext, const CGPoint thePoints [][2], const int theLength){
    for (int i = 0; i < theLength; ++i){
        IGDrawSegment (theContext, thePoints [i]);
    }
}

- (void) drawMonoscopioInContext: (CGContextRef) theContext inRect: (CGRect) theRect{
    const CGRect aInsetRect = CGRectInset(theRect, 0.5, 0.5);
    CGContextSetStrokeColorWithColor(theContext, [UIColor greenColor].CGColor);
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
    
    CGContextSetStrokeColorWithColor(theContext, [UIColor redColor].CGColor);
    CGContextStrokePath(theContext);
}

static CGPoint geoCircleOrigin (IGCDCircle * theCircle){
    return CGPointMake(theCircle.circle_pt_point.x.floatValue, theCircle.circle_pt_point.y.floatValue);
}

- (void) drawEllipseInContext: (CGContextRef) theContext atOrigin: (CGPoint) theOrigin withRadius: (CGSize) theRadius andColor: (UIColor *) theColor{
    CGContextSetFillColorWithColor(theContext, theColor.CGColor);
    CGContextFillEllipseInRect(theContext, CGRectMake(theOrigin.x-theRadius.width, theOrigin.y-theRadius.height, 2*theRadius.width, 2*theRadius.height));
    // CGContextStrokeEllipseInRect(theContext, CGRectMake(theOrigin.x-theRadius, theOrigin.y-theRadius, 2*theRadius, 2*theRadius));
}

- (void)drawLayerPrivate:(CALayer *)layer inContext:(CGContextRef)context {
    NSLog (@"%s - layer.frame: %@", __PRETTY_FUNCTION__, NSStringFromCGRect(layer.frame));
    NSParameterAssert(nil != self.fConnections);
    CGContextSaveGState(context);
    // [self drawMonoscopioInContext:context inRect:layer.frame];
#if 1
    NSArray * aCircleArray = self.fCircles;
    const CGFloat kZoomWidth = self->fBoundingBox.size.width/layer.frame.size.width;
    const CGFloat kZoomHeight = self->fBoundingBox.size.height/layer.frame.size.height;
    NSLog (@"%s - kZoomWidth: %@; kZoomHeight: %@", __PRETTY_FUNCTION__, @(kZoomWidth), @(kZoomHeight));
    {
    NSArray * aColorArray = @[[UIColor blackColor], [UIColor greenColor]];
    for (IGCDCircle * aCircle in aCircleArray){
        const CGPoint aOriginR = geoCircleOrigin (aCircle);
        const CGPoint aOrigin = CGPointMake (aOriginR.x - self->fBoundingBox.origin.x, aOriginR.y - self->fBoundingBox.origin.y);
        const CGFloat aRadius = aCircle.radius.floatValue;
        const CGPoint aOriginZoom = CGPointMake (aOrigin.x/kZoomWidth, aOrigin.y/kZoomHeight);
        const CGSize aRadiusZoom = CGSizeMake (aRadius/kZoomWidth, aRadius/kZoomHeight);
        
        const BOOL aSelected = [aCircle.circle_pt_status.circle_status_description isEqual:[[self.fPresentingViewController class]circleStatusToNSString:eCircleStatusSelected]];
        UIColor * aColor = aColorArray [aSelected];
        [self drawEllipseInContext: context atOrigin:aOriginZoom withRadius:aRadiusZoom andColor: aColor];
    }
    }
    {
    NSArray * aConnectionArray = self.fConnections;
    NSArray * aColorArray = @[[UIColor grayColor], [UIColor redColor]];
    for (IGCDConnection * aConnection in aConnectionArray){
        const CGPoint aOriginR1 = geoCircleOrigin (aConnection.connection_pt_circle1);
        const CGPoint aOrigin1 = CGPointMake (aOriginR1.x - self->fBoundingBox.origin.x, aOriginR1.y - self->fBoundingBox.origin.y);
        const CGPoint aOriginZoom1 = CGPointMake (aOrigin1.x/kZoomWidth, aOrigin1.y/kZoomHeight);
        
        const CGPoint aOriginR2 = geoCircleOrigin (aConnection.connection_pt_circle2);
        const CGPoint aOrigin2 = CGPointMake (aOriginR2.x - self->fBoundingBox.origin.x, aOriginR2.y - self->fBoundingBox.origin.y);
        const CGPoint aOriginZoom2 = CGPointMake (aOrigin2.x/kZoomWidth, aOrigin2.y/kZoomHeight);
        const CGPoint aSegment []={aOriginZoom1, aOriginZoom2};
        
        const BOOL aSelected = [aConnection.connection_pt_circle1.circle_pt_status.circle_status_description isEqual:[[self.fPresentingViewController class]circleStatusToNSString:eCircleStatusSelected]];
        IGDrawSegment(context, aSegment);
        UIColor * aColor = aColorArray [aSelected];
        CGContextSetStrokeColorWithColor(context, aColor.CGColor);
        CGContextStrokePath(context);
    }
    }
#endif
    CGContextRestoreGState(context);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    typeof(self) __block bSelf = self;
    [[self class] executeBlock:^{
        id ret = nil;
        [bSelf drawLayerPrivate:layer inContext:context];
        return ret;
    } withTag:@"drawLayer:inContext:"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)actionBack:(id)sender {
    UIViewController *source = self;
    UIViewController *destination = self.fPresentingViewController;
    UIWindow *window = source.view.window;
    
    CATransition *transition = [CATransition animation];
    [transition setDuration:kIGAnimationTransitionDuration];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    [transition setFillMode:kCAFillModeForwards];
    [transition setRemovedOnCompletion:YES];
    
    
    [window.layer addAnimation:transition forKey:kCATransition];
    [window setRootViewController:destination];
}

- (IBAction)actionTableView:(id)sender {
    if (nil == self.fNodeViewController){
        self.fNodeViewController = [[IGNodeViewController alloc] init];
        self.fNodeViewController.fRootViewController = self.fPresentingViewController;
        self.fNodeViewController.fGeoViewController = self;
        self.fNodeViewController.fInfo = self.fInfo;
        [self.view addSubview:self.fNodeViewController.view];
    }
    const CGRect aFrame = self.fNodeViewController.view.frame;
    self.fNodeViewController.view.frame = CGRectMake(10, 10, aFrame.size.width, aFrame.size.height);
    self.fNodeViewController.view.hidden = NO;
}

/*
 { URL: http://vendor/Graph01.json } { status code: 200, headers {
 "Accept-Ranges" = bytes;
 "Cache-Control" = "max-age=186400";
 Connection = "Keep-Alive";
 "Content-Encoding" = gzip;
 "Content-Length" = 1447;
 "Content-Type" = "text/plain; charset=iso-8859-1";
 Date = "Sun, 14 Jun 2015 15:52:16 GMT";
 Etag = "\"22061-1af8-516973cd4b900\"";
 Expires = "Tue, 16 Jun 2015 19:38:56 GMT";
 "Keep-Alive" = "timeout=3, max=100";
 "Last-Modified" = "Thu, 21 May 2015 13:08:20 GMT";
 Server = Apache;
 Vary = "Accept-Encoding";
 Via = "1.1 test.paginegialle.it";
 } };
 
 { URL: http://192.168.1.33:8082/Graph01.json } { status code: 200, headers {
 "Accept-Ranges" = bytes;
 Connection = "Keep-Alive";
 "Content-Length" = 6904;
 "Content-Type" = "application/json";
 Date = "Sun, 14 Jun 2015 15:41:56 GMT";
 Etag = "\"1af8-5183c8c081e80\"";
 "Keep-Alive" = "timeout=5, max=100";
 "Last-Modified" = "Thu, 11 Jun 2015 11:46:50 GMT";
 Server = "Apache/2.4.10 (Unix) PHP/5.5.20";
 } };
 */

- (NSArray *) dataToJSON: (NSData *) theData{
    NSParameterAssert(nil != theData);
    NSError * aError = nil;
    id ret = [NSJSONSerialization JSONObjectWithData:theData options:0 error:&aError];
    if (nil == ret){
        [self.fPresentingViewController IGHandleError:aError];
    }
    return ret;
}

- (IBAction)actionFetch:(UIButton *)sender {
    // http://192.168.1.33:8082/Graph01.json
    // http://vendor/test/Graph03.json
    // http://localhost:8082/Graph01.json

    sender.enabled = FALSE;
    self.fHeader.text = @"fetching...";
    // NSURL * aURL = [NSURL URLWithString:@"http://192.168.1.33:8082/Graph01.json"];
    // NSURL * aURL = [NSURL URLWithString:@"http://vendor/test/Graph03.json"];
    NSString * aStringFetchURL = self.fTextFieldFetchURL.text;
    NSURL * aURL = [NSURL URLWithString:aStringFetchURL];
    NSURLRequest * aURLRequest = [NSURLRequest requestWithURL:aURL];
    // NSURLConnection * aURLConnection = [NSURLConnection connectionWithRequest:aURLRequest delegate:nil];
    // aURLRequest
    NSOperationQueue * __block aOperationQueue = [[NSOperationQueue alloc] init];
    typeof(self) __block bSelf = self;
    [NSURLConnection sendAsynchronousRequest:aURLRequest
                                       queue: aOperationQueue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError){
                               // NSString * aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog (@"%s - response: %@; error: %@; userInfo: %@", __PRETTY_FUNCTION__, response.description, connectionError.localizedDescription, connectionError.userInfo);
                               // NSLog (@"%s - aString: %@", __PRETTY_FUNCTION__, aString);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (nil != connectionError){
                                       [bSelf.fPresentingViewController IGHandleError:connectionError];
                                   }
                                   else{
                                       NSArray * aList = [bSelf dataToJSON:data];
                                       // NSLog (@"%s - aList: %@", __PRETTY_FUNCTION__, aList.description);
                                       if (nil != aList){
                                           [bSelf.fPresentingViewController geoHandleFetch: aList inGeo:bSelf.fInfo[@"geo"]];
                                           [bSelf.fPresentingViewController geoSave];
                                        }
                                   }
                                   [bSelf updateUI];
                                   [bSelf.fNodeViewController updateUI];
                                   sender.enabled = TRUE;
                               });
                           }];
}

@end
