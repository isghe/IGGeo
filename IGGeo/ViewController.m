//
//  ViewController.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 11/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "IGCDAGeoStatus.h"
#import "IGCDHGeo.h"
#import "IGHGeoTableViewCell.h"
#import "NSObject+ExtraProperties.h"
#import "IGGeoViewController.h"
#import "IGCDPoint.h"
#import "IGCDCircle.h"
#import "IGCDConnection.h"
#import "UIAlertController+Showable.h"
#import "IGCDACircleStatus.h"

@interface ViewController ()

#pragma mark - UI
@property (weak, nonatomic) IBOutlet UILabel *fHeader;
@property (weak, nonatomic) IBOutlet UIButton *fButtonSetup;
@property (weak, nonatomic) IBOutlet UIButton *fButtonPopulate;
@property (weak, nonatomic) IBOutlet UIButton *fButtonInsert;
@property (weak, nonatomic) IBOutlet UIButton *fButtonSelect;
@property (weak, nonatomic) IBOutlet UIButton *fButtonDeleteAll;
@property (weak, nonatomic) IBOutlet UITableView *fTableViewHGeo;

#pragma mark - CoreData Helper
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ViewController

- (void) IGHandleError: (NSError *) theError{
    NSParameterAssert(nil != theError);
    NSLog (@"%s - error: %@, %@", __PRETTY_FUNCTION__, theError, [theError userInfo]);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"IGGeo error"
                                                                   message:theError.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [alert show];
}

- (BOOL) geoStatusPopulated{
    return (nil != self.managedObjectContext) && [self loadGeoStatus].count > 0;
}

-(void) enableControls{
    self.fButtonSetup.enabled = (nil == self.managedObjectContext);
    const BOOL aPopulated = self.geoStatusPopulated;
    self.fButtonPopulate.enabled = (nil != self.managedObjectContext) && (FALSE == aPopulated);
    NSArray * aArray = @[self.fButtonInsert, self.fButtonSelect, self.fButtonDeleteAll];
    for (UIControl * aControl in aArray){
        aControl.enabled = (nil != self.managedObjectContext) && (TRUE == aPopulated);
    }
}

- (NSArray *) entityNames{
    NSMutableArray * ret = [[NSMutableArray alloc] initWithCapacity:self.managedObjectModel.entities.count];
    for (NSEntityDescription * aEntityDescription in self.managedObjectModel.entities){
        [ret addObject:aEntityDescription.name];
    }
    return ret;
}

- (void) setupCoreData{
    NSParameterAssert(nil == self.managedObjectModel);
    NSParameterAssert(nil == self.managedObjectContext);
    NSParameterAssert(nil == self.persistentStoreCoordinator);
    NSArray * aArray = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSLog (@"%s - aArray: %@", __PRETTY_FUNCTION__, aArray.description);
    NSURL *aURLUserDomain = aArray [0];
    // set up ManagedObjectModel
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IGGeo" withExtension:@"momd"];
    self->_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSLog (@"%s - entities: %@", __PRETTY_FUNCTION__, self.managedObjectModel.entities.description);
    NSArray * aEntityNames = self.entityNames;
    NSLog (@"%s - aEntityNames: %@", __PRETTY_FUNCTION__, aEntityNames);
   
    // set up PersistentStore
    NSURL *storeURL = [aURLUserDomain URLByAppendingPathComponent:@"Card.sqlite"];
    NSError *error = nil;
    self->_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [self IGHandleError:error];
        abort();
    }
    // set up managedObjectContext
    self->_managedObjectContext = [[NSManagedObjectContext alloc]init];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.fHeader.text = [NSString stringWithFormat:@"%s %s", __DATE__, __TIME__];
    [self enableControls];
}

- (void)viewWillAppear:(BOOL)animated{
    // Called when the view is about to made visible. Default does nothing
    [self.fTableViewHGeo reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)actionSetupCoreData:(id)sender {
    [self setupCoreData];
    [self.fTableViewHGeo reloadData];
    [self enableControls];
}

- (IBAction)actionPopulate:(id)sender {
    [self populateGeoStatus];
    [self populateCircleStatus];
    [self enableControls];
}

- (NSArray *) loadHGeo{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDHGeo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects){
        [self IGHandleError:error];
    }
    return fetchedObjects;
}

- (IBAction)actionSelect:(id)sender {
    NSArray * aNames = [self entityNames];
    NSMutableArray * aResult = [[NSMutableArray alloc] initWithCapacity:aNames.count + 1]; // +1 because of sigma
    NSUInteger aSigma = 0;
    for (NSString * aName in aNames){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:aName inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (nil == fetchedObjects){
            [self IGHandleError:error];
        }
        [aResult addObject:@{@"entity": aName, @"count": @(fetchedObjects.count)}];
        aSigma += fetchedObjects.count;
    }
    [aResult addObject:@{@"entity": @"SIGMA", @"count": @(aSigma)}];
    NSLog (@"%s - aResult: %@", __PRETTY_FUNCTION__, aResult);
}

- (IBAction)actionSelectOld:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDHGeo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSArray *fetchedObjects = [self loadHGeo];
    for (IGCDHGeo *info in fetchedObjects) {
        IGCDAGeoStatus * aStatus = info.geo_pt_status;
        NSLog(@"date: %@: status: %@;", info.dateTimeInsert, aStatus.geo_status_description);
    }
    [self.fTableViewHGeo reloadData];
    [self enableControls];
}

- (NSArray *) loadGeoStatus{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDAGeoStatus" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects){
        [self IGHandleError:error];
    }
    return fetchedObjects;
}

#pragma mark - populate
- (IBAction) populateGeoStatus{
    NSParameterAssert(0 == [self loadGeoStatus].count);
    NSArray * aArray = @[@"undefined", @"normal", @"deleted"];
    for (NSString * aString in aArray){
        IGCDAGeoStatus *aStatus = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"IGCDAGeoStatus"
                                          inManagedObjectContext:self.managedObjectContext];
        aStatus.geo_status_description = aString;
    }
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        [self IGHandleError:error];
    }
}

- (IBAction) populateCircleStatus{
    NSParameterAssert(0 == [self loadGeoStatus].count);
    NSArray * aArray = @[@"selected", @"not_selected"];
    for (NSString * aString in aArray){
        IGCDACircleStatus *aStatus = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"IGCDACircleStatus"
                                   inManagedObjectContext:self.managedObjectContext];
        aStatus.circle_status_description = aString;
    }
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        [self IGHandleError:error];
    }
}

- (IBAction)actionInsert:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDAGeoStatus" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"geo_status_description == %@", @"undefined"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (nil != fetchedObjects){
        NSAssert (fetchedObjects.count == 1, @"fetchedObjects.count == 1");
        IGCDAGeoStatus * aStatus = fetchedObjects [0];
        IGCDHGeo *aGeo = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"IGCDHGeo"
                                   inManagedObjectContext:context];
        aGeo.dateTimeInsert = [[NSDate alloc] init];
        aGeo.geo_pt_status = aStatus;

        if (![context save:&error]) {
            [self IGHandleError:error];
       }
    }
    else{
        [self IGHandleError:error];
    }
    [self.fTableViewHGeo reloadData];
    [self enableControls];
}

- (IBAction)actionDeleteAll:(id)sender {
    NSMutableArray * aManagedObjectsToDelete = [[NSMutableArray alloc] init];
    for (NSEntityDescription *entity in self.managedObjectModel.entities){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if(nil != fetchedObjects){
            for (NSManagedObject *aManagedObject in fetchedObjects) {
                [aManagedObjectsToDelete addObject:aManagedObject];
            }
        }
        else{
            [self IGHandleError:error];
        }
    }
    NSLog (@"%s - %@", __PRETTY_FUNCTION__, aManagedObjectsToDelete);
    for (NSManagedObject *aManagedObject in aManagedObjectsToDelete){
        [self.managedObjectContext deleteObject:aManagedObject];
    }

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self IGHandleError:error];
    }
    [self.fTableViewHGeo reloadData];
    [self enableControls];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = 0;
    if ([self geoStatusPopulated]){
        ret =[self loadHGeo].count;
    }
    return ret;
}

- (void)actionDeleteCell:(id)sender{
    UIButton * aButton = sender;
    NSDictionary * aInfo = aButton.superview.extraProperties [@"ig_geo"];
    NSParameterAssert([aInfo [@"geo"] isKindOfClass:[IGCDHGeo class]]);
    IGCDHGeo * aGeo = aInfo [@"geo"];
    [self geoDeleteGeo:aGeo];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self IGHandleError:error];
    }
    [self.fTableViewHGeo reloadData];
    [self enableControls];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"Cell";
    NSArray * aHGeo = [self loadHGeo];
    IGHGeoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    // NSParameterAssert(nil == cell.fButtonDelete.tag);

    // Set up the cell...
    IGCDHGeo *aGeo = aHGeo [indexPath.row];
    NSNumber * aCircleCount = @([self geoCircles:aGeo].count);
    // NSNumber * aConnectionCounter = @([self geoConnectionsCountInGeo:aGeo]);
    cell.textLabel.text = [NSString stringWithFormat: @"%@/%@ - %@; Circles: %@", @(indexPath.row + 1), @(aHGeo.count), aGeo.dateTimeInsert.description, aCircleCount];
    cell.fLabelStatus.text = [NSString stringWithFormat:@"%@",
                                 aGeo.geo_pt_status.geo_status_description];
    cell.contentView.extraProperties [@"ig_geo"] = @{@"geo": aGeo, @"index_path": indexPath};
    [cell.fButtonDelete addTarget:self action:@selector(actionDeleteCell:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSParameterAssert([segue.destinationViewController isKindOfClass:[IGGeoViewController class]]);
    NSParameterAssert([sender isKindOfClass:[UITableViewCell class]]);
    [super prepareForSegue:segue sender:sender];
    IGGeoViewController * aViewController = segue.destinationViewController;
    NSDictionary * aInfo = ((UITableViewCell *)sender).contentView.extraProperties [@"ig_geo"];
#if DEBUG
    {
        NSIndexPath * aIndexPath1 = [self.fTableViewHGeo indexPathForCell:sender];
        NSIndexPath * aIndexPath2 = aInfo [@"index_path"];
        NSParameterAssert ((aIndexPath1.section == aIndexPath2.section) && (aIndexPath1.row == aIndexPath2.row));
    }
#endif
    aViewController.fInfo = aInfo;
}

#if 0
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    IGGeoViewController * aGeoViewController = [[IGGeoViewController alloc] init];
    [self presentViewController:aGeoViewController animated:YES completion:^{}];
     */
}
#endif

#pragma mark - geo
- (IGCDCircle *) geoInsertCircle: (IGCDHGeo *) theGeo withOrigin: (CGPoint) theOrigin andRadious: (CGFloat) theRadious{
    NSParameterAssert(nil != theGeo);
    
    IGCDPoint *aPoint = [NSEntityDescription
                      insertNewObjectForEntityForName:@"IGCDPoint"
                      inManagedObjectContext:self.managedObjectContext];
    aPoint.x = @(theOrigin.x);
    aPoint.y = @(theOrigin.y);
    IGCDCircle *aCircle = [NSEntityDescription
                         insertNewObjectForEntityForName:@"IGCDCircle"
                         inManagedObjectContext:self.managedObjectContext];
    aCircle.radius = @(theRadious);
    aCircle.circle_pt_point = aPoint;
    aCircle.circle_pt_geo = theGeo;
    return aCircle;
}

- (NSArray *) geoCircles: (IGCDHGeo *) theGeo{
    NSParameterAssert(nil != theGeo);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDCircle" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"circle_pt_geo == %@", theGeo];

    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects){
        [self IGHandleError:error];
    }
    return fetchedObjects;
}

- (NSArray *) geoConnections: (IGCDCircle *) theCircle{
    NSParameterAssert(nil != theCircle);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"IGCDConnection" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection_pt_circle1 == %@", theCircle];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == fetchedObjects){
        [self IGHandleError:error];
    }
    return fetchedObjects;
}

- (NSArray *) geoConnectionsInGeo: (IGCDHGeo *) theGeo{
    NSMutableArray * ret = [[NSMutableArray alloc] init];
    for (IGCDCircle * aCircle in [self geoCircles:theGeo]){
        [ret  addObjectsFromArray:[self geoConnections:aCircle]];
    }
    return ret;
}

- (NSUInteger) geoConnectionsCountInGeo: (IGCDHGeo *) theGeo{
    NSParameterAssert(nil != theGeo);
    NSUInteger ret = 0;
    for (IGCDCircle * aCircle in [self geoCircles:theGeo]){
        ret += [self geoConnections:aCircle].count;
    }
    return ret;
}

- (void) geoDeleteCircle: (IGCDCircle *) theCircle{
    NSParameterAssert(nil != theCircle);
    NSArray * aConnections = [self geoConnections:theCircle];
    for (IGCDConnection * aConnection in aConnections){
        [self.managedObjectContext deleteObject:aConnection];
    }
    [self.managedObjectContext deleteObject:theCircle.circle_pt_point];
    [self.managedObjectContext deleteObject:theCircle];
}

- (void) geoDeleteCirclesInGeo: (IGCDHGeo *) theGeo{
    NSLog (@"%s", __PRETTY_FUNCTION__);
    NSParameterAssert(nil != theGeo);
    NSArray * aCircles = [self geoCircles:theGeo];
    for (IGCDCircle * aCircle in aCircles){
        [self geoDeleteCircle:aCircle];
    }
}

- (void) geoDeleteGeo: (IGCDHGeo *) theGeo{
    NSParameterAssert(nil != theGeo);
    [self geoDeleteCirclesInGeo:theGeo];
    [self.managedObjectContext deleteObject:theGeo];
}

- (void) geoSave{
    NSLog (@"%s", __PRETTY_FUNCTION__);
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self IGHandleError:error];
    }
    else{
        NSLog (@"%s - OK", __PRETTY_FUNCTION__);
    }
}

- (BOOL) geoIsValidCircle: (NSDictionary *) theDictionary{
    NSParameterAssert(nil != theDictionary);
    BOOL ret = TRUE;

    NSArray * aNumberFields = @[@"x", @"y", @"r"];
    for (NSString * aFiled in aNumberFields){
        ret = [theDictionary [aFiled] isKindOfClass: [NSNumber class]];
        if (FALSE == ret){
            break;
        }
    }
    if (TRUE == ret){
        ret = [theDictionary [@"l"] isKindOfClass:[NSArray class]];
        if (TRUE == ret){
            for (id aCandidateInteger in theDictionary [@"l"]){
                ret = [aCandidateInteger isKindOfClass:[NSNumber class]];
                if (FALSE == ret){
                    break;
                }
            }
        }
    }
    return ret;
}

- (BOOL) geoIsValidArray: (NSArray *) theArray{
    NSParameterAssert(nil != theArray);
    BOOL ret = TRUE;
    for (NSDictionary * aCircle in theArray){
        ret = [self geoIsValidCircle:aCircle];
        if (FALSE == ret){
            break;
        }
    }
    return ret;
}

- (void) geoInsertConnection: (IGCDHGeo *) theGeo fromCircle: (IGCDCircle *) theCircleFrom toCircle: (IGCDCircle *) theCircleTo{
    NSParameterAssert(nil != theGeo);
    NSParameterAssert(nil != theCircleFrom);
    NSParameterAssert(nil != theCircleTo);

    IGCDConnection *aConnection = [NSEntityDescription
                         insertNewObjectForEntityForName:@"IGCDConnection"
                         inManagedObjectContext:self.managedObjectContext];
    aConnection.connection_pt_circle1 = theCircleFrom;
    aConnection.connection_pt_circle2 = theCircleTo;
}

- (void) geoHandleFetch: (NSArray *) theArray inGeo: (IGCDHGeo *) theGeo{
    NSParameterAssert(nil != theGeo);
    NSParameterAssert(nil != theArray);
    const BOOL aIsValidArray = [self geoIsValidArray:theArray];
    NSLog (@"%s - aIsValidArray: %@", __PRETTY_FUNCTION__, @(aIsValidArray));
    NSLog (@"%s - theArray.count: %@", __PRETTY_FUNCTION__, @(theArray.count));
    if (TRUE == aIsValidArray){
        [self geoDeleteCirclesInGeo:theGeo];
        NSLog (@"%s - inserting Circles", __PRETTY_FUNCTION__);

        NSMutableArray * aCDCircleArray = [[NSMutableArray alloc] initWithCapacity:theArray.count];
        for (NSDictionary * aCircle in theArray){
            NSNumber * aX = aCircle [@"x"];
            NSNumber * aY = aCircle [@"y"];
            NSNumber * aRadious = aCircle [@"r"];
            const CGPoint aOrigin = CGPointMake(aX.floatValue, aY.floatValue);
            IGCDCircle * aCDCircle = [self geoInsertCircle:theGeo withOrigin:aOrigin andRadious:aRadious.floatValue];
            [aCDCircleArray addObject:@{@"circle": aCDCircle, @"connections": aCircle [@"l"]}];
        }

        NSLog (@"%s - inserting Connections", __PRETTY_FUNCTION__);
        for (NSDictionary * aDictionary in aCDCircleArray){
            IGCDCircle * aCircleFrom = aDictionary [@"circle"];
            NSArray * aConnections = aDictionary [@"connections"];
            for (NSNumber * aConnection in aConnections){
                NSDictionary * aDictionaryTo = aCDCircleArray [aConnection.integerValue]; // - 1?
                IGCDCircle * aCircleTo = aDictionaryTo [@"circle"];
                [self geoInsertConnection: theGeo fromCircle:aCircleFrom toCircle:aCircleTo];
            }
        }
    }
}
@end
