//
//  ControllerViewController.m
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBORobotControlViewController.h"
#import "RMBOEditNavigationViewController.h"
#import "AppDelegate.h"
#import "UIColor+RMBOColors.h"
#import "RMBOActionCategoryCell.h"
#import "RMBOCategory.h"
#import "RMBOActionDataSource.h"
#import "RMBOTabCell.h"
#import "RMBOPopoverMenuViewController.h"
#import "UIImage+RMBOTab.h"

#include <tgmath.h>
#pragma mark C O N S T A N T S

#define kRMBOMaxMutlipeerConnections 1
#define kRMBOConnectionMenuOption 1
#define kRMBOEditorMenuOption 0
#define kRMBOShowkitLoginOption 2
#define kRMBOServiceType @"origami-romibo"

#define kRMBOControlsDisabledAlpha 0.0

//Commands
#define kRMBOSpeakPhrase @"kRMBOSpeakPhrase"
#define kRMBOMoveRobot @"kRMBOMoveRobot"
#define kRMBOHeadTilt @"kRMBOHeadTilt"
#define kRMBODebugLogMessage @"kRMBODebugLogMessage"
#define kRMBOTurnInPlaceClockwise @"kRMBOTurnInPlaceClockwise"
#define kRMBOTurnInPlaceCounterClockwise @"kRMBOTurnInPlaceCounterClockwise"
#define kRMBOStopRobotMovement @"kRMBOStopRobotMovement"
#define kRMBOChangeMood @"kRMBOChangeMood"

//Video
#define kRMBOShowkitAPIKey @"05070922-5868-4283-b21c-dfcf88a602ce"
#define kRMBOShowkitAccountNumber @"584"

//Pallets
#define kRMBOPalletTabDisabled 0.4f

#define kRMBOMinimumMovementThreshold 0.125


@implementation RMBORobotControlViewController
#pragma mark V I E W    M A N A G E M E N T 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMultipeerConnectivity];
    
    if (!_mainContext) {
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _mainContext = [del managedObjectContext];
        currentPage = 0;
    }
    
    [self customizeViews];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(showkitStatusChanging:)
//     name:SHKConnectionStatusChangedNotification
//     object:nil];
    _lastX = 0.0f;
    _lastY = 0.0f;
    
    _isV6Hardware = [self detectV6Hardware];
    // TODO: add UI so this can be set by the user and persist between
    // invocations so the setting always works. -ETJ 19 Aug 2014
    _leftRightMotorBalance = 1.0f;
    
    // TODO: Unhide the extra expression buttons when we've got working emotion
    // eyes again. -ETJ 22 Aug 2014
    _curiousButton.hidden = YES;
    _excitedButton.hidden = YES;
    _indifferentButton.hidden = YES;
    _twitterpatedButton.hidden = YES;
}

- (void)awakeFromNib
{
    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void) reloadCategoriesAndActions {
    [self loadCategoriesFromPersistentStore];
    [_cateogriesCollectionView reloadData];
    [_tabCollectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadCategoriesFromPersistentStore];
    [_cateogriesCollectionView reloadData];
    [_tabCollectionView reloadData];
    if (_fetchedCategories.count > 0) {
        
        if (_selectedTab) {
            [_tabCollectionView selectItemAtIndexPath:_selectedTab animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        else {
            [_tabCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        
    }
    CGAffineTransform trans = CGAffineTransformMakeRotation((float)(M_PI * -0.5f));
    _headTiltSlider.transform = trans;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeViews
{
    UIColor * backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
    [self.view setBackgroundColor:backgroundColor];

//    [self.view setBackgroundColor:[UIColor rmbo_blueStarBackground]];
}

- (void)loadEditorView
{
    UIStoryboard *editStoryboard = [UIStoryboard storyboardWithName:@"EditStoryboard" bundle:[NSBundle mainBundle]];
    
    RMBOEditNavigationViewController *vc = [editStoryboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showMenuPopover:(id)sender
{
    RMBOPopoverMenuViewController *vc;
    vc = [[RMBOPopoverMenuViewController alloc] initWithStyle:UITableViewStyleGrouped 
                                                romiboConnected:_connectedToRobot 
                                                showkitLoggedIn:_loggedIntoShowkit];
    [vc.tableView setDelegate:self];
    
    _menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    [_menuPopoverController setPopoverContentSize:CGSizeMake(320, 250)];
    [_menuPopoverController presentPopoverFromRect:[_editorButton frame] 
                                            inView:self.view 
                          permittedArrowDirections:UIPopoverArrowDirectionAny 
                                          animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:_cateogriesCollectionView]) {
        return [_fetchedCategories count];
    }
    else {
        return [_fetchedCategories count];
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_cateogriesCollectionView]) {
        RMBOActionCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryView" forIndexPath:indexPath];
        
        if (![cell dataSource]) {
            cell.dataSource = [[RMBOActionDataSource alloc] init];
            cell.dataSource.delegate = self;
        }
        
        cell.dataSource.collectionView = cell.collectionView;
        [[cell dataSource] setFetchedButtons:(NSMutableArray *)[self loadActionsFromPersistentStoreWithCateogry:_fetchedCategories[[indexPath row]]]];
        [[cell collectionView] setDataSource:[cell dataSource]];
        
        [[cell collectionView] reloadData];
        
        return cell;
    }
    else {
        RMBOTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tabView" forIndexPath:indexPath];
        
        
        [[cell tabImage] setImage:[UIImage rmbo_tabImageWithSize:CGSizeMake(cell.frame.size.width - 5, cell.frame.size.height) andColor:[_fetchedCategories[indexPath.row] pageColor]]];
        
        if ([cell isSelected]) {
            [[cell tabImage] setAlpha:1.0];
            [[cell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
            [[cell categoryName] setAlpha:1.0];
        }
        else {
            [[cell categoryName] setAlpha:0.5];
            [[cell tabImage] setAlpha:kRMBOPalletTabDisabled];
            [[cell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        }
        [[cell categoryName] setText:[_fetchedCategories[indexPath.row] name]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_tabCollectionView]) {
        RMBOTabCell *cell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:indexPath];
        [[cell categoryName] setAlpha:0.5];
        [[cell tabImage] setAlpha:kRMBOPalletTabDisabled];
        [[cell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_tabCollectionView]) {
        RMBOTabCell *cell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:indexPath];
        [[cell tabImage] setAlpha:1.0];
        [[cell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
        [[cell categoryName] setAlpha:1.0];
        [_cateogriesCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_cateogriesCollectionView]) {
        NSUInteger newPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
        if (newPage != currentPage) {
            if (_fetchedCategories.count > newPage) {
                RMBOTabCell *oldCell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0]];
                [[oldCell categoryName] setAlpha:0.5];
                [[oldCell tabImage] setAlpha:kRMBOPalletTabDisabled];
                [[oldCell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                [_tabCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0] animated:YES];
                
                RMBOTabCell *newCell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:newPage inSection:0]];
                [[newCell tabImage] setAlpha:1.0];
                [[newCell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
                [[newCell categoryName] setAlpha:1.0];
                [_tabCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:newPage inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                
                currentPage = newPage;
                
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if ([scrollView isEqual:_cateogriesCollectionView]) {
            NSUInteger newPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
            if (newPage != currentPage) {
                if (_fetchedCategories.count > newPage) {
                    RMBOTabCell *oldCell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0]];
                    [[oldCell categoryName] setAlpha:0.5];
                    [[oldCell tabImage] setAlpha:(float)kRMBOPalletTabDisabled];
                    [[oldCell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
                    [_tabCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0] animated:YES];
                    
                    RMBOTabCell *newCell = (RMBOTabCell *)[_tabCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:newPage inSection:0]];
                    [[newCell tabImage] setAlpha:1.0];
                    [[newCell categoryName] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
                    [[newCell categoryName] setAlpha:1.0];
                    [_tabCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:newPage inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                    
                    currentPage = newPage;
                    
                }
            }
        }

    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_tabCollectionView]) {
        static UIFont *_labelFont = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _labelFont = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
        });
        
        NSString *buttonTitle = [_fetchedCategories[indexPath.row] name];
        
        CGSize textSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName:_labelFont}];
        
        CGFloat strikeWidth = textSize.width + 70;
        NSLog(@"%f", strikeWidth);
        
        return CGSizeMake(MAX(100, strikeWidth), 50);
    }
    return CGSizeMake(768, 505);
}

- (void)loadCategoriesFromPersistentStore
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:_mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSError *error;
    
    _fetchedCategories = [_mainContext executeFetchRequest:request error:&error];
    
}

- (NSArray *)loadActionsFromPersistentStoreWithCateogry:(RMBOCategory *)category
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action" inManagedObjectContext:_mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@", category];
    [request setPredicate:predicate];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"threeBasedIndex" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSError *error;
    
    return [_mainContext executeFetchRequest:request error:&error];
}

- (void)orientationChanged:(NSNotification *)notification
{
    /*
     UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
     if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
     !isShowingLandscapeView)
     {
     [self performSegueWithIdentifier:@"landscapeSegue" sender:self];
     isShowingLandscapeView = YES;
     }
     else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
     isShowingLandscapeView)
     {
     [self dismissViewControllerAnimated:NO completion:nil];
     isShowingLandscapeView = NO;
     }
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RMBORobotControlViewController *vc = [segue destinationViewController];
    [vc setSelectedTab:[_tabCollectionView indexPathsForSelectedItems][0]];
}

#pragma mark H A R D W A R E 
- (BOOL)detectV6Hardware
{
    // TODO: Really, we're better off with a version number rather than a V6 yes/no bit.
    // FIXME: Replace this with valid detection code ASAP -ETJ 19 Aug 2014
    return NO;
}

- (void)setupMultipeerConnectivity
{
    [self disableRobotControls];
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    _session = [[MCSession alloc] initWithPeer:peerId];
    [_session setDelegate:self];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_menuPopoverController dismissPopoverAnimated:YES];
    switch( [indexPath row]){
        case kRMBOConnectionMenuOption: [self manageRobotConnection]; break;
        case kRMBOEditorMenuOption:     [self loadEditorView]; break;
        case kRMBOShowkitLoginOption:   [self manageShowkitLogin]; break;
    }
    
}

- (void)manageRobotConnection
{
    if (!_connectedToRobot) {
        _multipeerBrowser = [[MCBrowserViewController alloc] initWithServiceType:kRMBOServiceType session:_session];
        [_multipeerBrowser setMaximumNumberOfPeers:kRMBOMaxMutlipeerConnections];
        [_multipeerBrowser setDelegate:self];
        [self presentViewController:_multipeerBrowser animated:YES completion:nil];
        
        /* ETJ DEBUG
        NOTE,19 Aug 2014: Previous versions of the robot had a single point of connection.
        We now have A) an iPod for sound and eye animations, and
                    B) a custom Bluetooth LE board to control motors
        
        Below, we'll add the Bluetooth connection invisibly.  This is naive; in
        a room where more than one Romibo is present, we need to make sure that
        each robot's iPod and Bluetooth board are associated so we don't connect
        to one Romibo's eyes and another Romibo's motors.
        // END DEBUG */
        
        [self addTagButtonPressed:nil];
    }
    else {
        UIAlertView *disconnectView = [[UIAlertView alloc] initWithTitle:@"Disconnect from Robot?" 
                            message:@"Are you sure you want to disconect from the robot?" 
                           delegate:self 
                  cancelButtonTitle:@"Cancel" 
                  otherButtonTitles:@"Disconnect", nil];
        [disconnectView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_showkitLoginAlertView]) {
        if (buttonIndex == 1) {
//            [ShowKit login:[NSString stringWithFormat:@"%@.%@", kRMBOShowkitAccountNumber, [[alertView textFieldAtIndex:0] text]]
//                  password:[[alertView textFieldAtIndex:1] text]
//       withCompletionBlock:^(NSString *const connectionStatus) {
//                NSLog(@"%@", connectionStatus);
//                [UIView animateWithDuration:0.4 animations:^{
//                    [_manageShowKitButton setAlpha:1.0];
//                }];
//            }];
        }
    }
    else {
        if (buttonIndex == 1) {
            [_session disconnect];
            _connectedToRobot = NO;
            // TODO: add method to disconnect from BTLE board here. -ETJ 20 Aug 2014
            [self setupMultipeerConnectivity];
        }
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [_multipeerBrowser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [_multipeerBrowser dismissViewControllerAnimated:YES completion:nil];
    _connectedToRobot = YES;
}

- (void)actionDataSource:(RMBOActionDataSource *)dataSource userWantsRobotToSpeakPhrase:(NSString *)phrase atRate:(float)speechRate
{
    [self sendSpeechPhraseToRobot:phrase atSpeechRate:speechRate];
}

- (void)sendSpeechPhraseToRobot:(NSString *)phrase atSpeechRate:(float)speechRate
{
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOSpeakPhrase, @"phrase" : phrase, @"speechRate" : [NSNumber numberWithFloat:speechRate]};
        [self sendCommandToRobot:params];

    }
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick
{
    [self moveRobotWithX:analogueStick.xValue andY:analogueStick.yValue];
}

- (void)moveRobotWithX:(CGFloat)xValue andY:(CGFloat)yValue
{
    if (_connectedToRobot) {
        
        CGFloat xCheck = __tg_fabs(_lastX - xValue);
        CGFloat yCheck = __tg_fabs(_lastY - yValue);
        
        float x = (float)xValue;
        float y = (float)yValue;

        NSLog(@"moveRobotWithX: %f  Y: %f   xCheck: %f  yCheck: %f", xValue, yValue, xCheck, yCheck);

        NSDictionary *params = @{@"command" : kRMBOMoveRobot, @"x" : [NSNumber numberWithFloat:x], @"y" : [NSNumber numberWithFloat:y]};
        [self sendCommandToRobot:params];

        _lastX = xValue;
        _lastY = yValue;
    }
}

- (void)stopRobotMovement
{
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOStopRobotMovement, @"timestamp" : [NSDate date]};
        [self sendCommandToRobot:params];
    }
}

- (void)tiltRobotHeadToAngle:(CGFloat)angle
{
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOHeadTilt, @"angle" : [NSNumber numberWithFloat:(float)angle]};
        [self sendCommandToRobot:params];
    }
}

- (void)turnRobotClockwise:(id)sender
{
    if (_connectedToRobot && isTurningClockwise) {
        NSDictionary *params = @{@"command" : kRMBOTurnInPlaceClockwise, @"timestamp" : [NSDate date]};
        [self sendCommandToRobot:params];
    }
}

- (void)turnRobotCounterClockwise:(id)sender
{
    if (_connectedToRobot && isTurningCounterclockwise) {
        NSDictionary *params = @{@"command" : kRMBOTurnInPlaceCounterClockwise, @"timestamp" : [NSDate date]};
        [self sendCommandToRobot:params];
    }

}

- (IBAction)beginTurnRobotInPlaceClockwiseAction:(id)sender
{
    [self turnRobotClockwise:self];
    isTurningClockwise = YES;
    _turningTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(turnRobotClockwise:) userInfo:nil repeats:YES];
}

- (IBAction)beginTurnRobotInPlaceCounterClockwiseAction:(id)sender
{
    [self turnRobotCounterClockwise:self];
    isTurningCounterclockwise = YES;
    _turningTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(turnRobotCounterClockwise:) userInfo:nil repeats:YES];
}

- (IBAction)endTurnRobotInPlaceClockwiseAction:(id)sender
{
    [self stopRobotMovement];
    isTurningClockwise = NO;
    [_turningTimer invalidate];
    _turningTimer = nil;
}

- (IBAction)endTurnRobotInPlaceCounterClockwiseAction:(id)sender
{
    [self stopRobotMovement];
    isTurningCounterclockwise = NO;
    [_turningTimer invalidate];
    _turningTimer = nil;
}


#pragma mark S T E E R I N G
- (UInt32)commandBytesForLeftMotor:(SInt8)leftMotor
                         rightMotor:(SInt8)rightMotor
                      leftRightTilt:(UInt8)leftRightTilt
                    forwardBackTilt:(UInt8)forwardBackTilt
{
    UInt32 commandBytes = 0;
    UInt8 *cbPointer = (UInt8 *)&commandBytes;
    cbPointer[0] = leftMotor;
    cbPointer[1] = rightMotor;
    cbPointer[2] = leftRightTilt;
    cbPointer[3] = forwardBackTilt;
    
    return commandBytes;
}                            

- (void)motorStrengthsForAnalogStickX:(float)x
                                    y:(float)y 
                             destLeft:(SInt8 *)destLeft 
                            destRight:(SInt8 *)destRight;
{
    // x & y should fall in (-1,1)
    float lMotor, rMotor;
    
    // A Square region in the center of the analog stick where we default
    // to no motion.
    float centerZone = 0.5;
    
    // Define wedge-shaped turn-in-place zones
    // from the center point of the pad to +/- turn_zone_angle degrees
    // on either side.  In those zones, make motor speed identical and 
    // speed of turn based on distance from the center
    // (not from the y-axis as in normal driving)    
    int turnOnlyZoneAngle = 15;
    
    // usually atan2 is y, x, but we want angle w.r.t x=0
    // like a car, not y=0 like a cartesian graph     
    float theta = (float)(atan2( x, y)/M_PI * 180.0); // degrees
    
    // Centered joystick - no action
    if  ((-centerZone/2 <= x && x <= centerZone/2) &&
         (-centerZone/2 <= y && y <= centerZone/2)){
        lMotor = 0;
        rMotor = 0;    
    }
    
    // Turn-only zone
    else if ( 90-turnOnlyZoneAngle <= fabs(theta) && fabs(theta) <= 90+turnOnlyZoneAngle){
        // Relate speed of turn to distance from center
        float motorSpeed = (float)sqrt( x*x + y*y);
        
        // Buuut... turns feel twitchy and too fast.  Instead, we want slower 
        // speed closer to the center and  
        motorSpeed = (float)pow( motorSpeed, 2);
        
        // because x & y describe a 2-unit square, not a circle, 
        // clip motorSpeed to 1
        motorSpeed = MIN( 1, motorSpeed);
    
        int directionMult = theta >=0 ? 1 : -1;
        lMotor = motorSpeed * directionMult;
        rMotor = -1 * lMotor; 
    }
    // Normal steering
    else{
        // Take base speed for both motors from y axis
        lMotor = y;
        rMotor = y;

        // Decrease speed of the motor in the direction of turn
        // linearly from the center to the edge of the turn-only zone 
        float singleQuadrantTheta = (float)fabs(theta);
        if (singleQuadrantTheta > 90){
            singleQuadrantTheta = 180 - singleQuadrantTheta;
        }
        // 0 -> 1,   turnOnlyZoneAngle -> 0
        float turnScale = (float)(1.0 - singleQuadrantTheta/(90 - turnOnlyZoneAngle));
    
        if (theta < 0){ lMotor *= turnScale;}
        else{           rMotor *= turnScale;}
    }
    *destLeft = scaleToSInt8( lMotor, -1.0f, 1.0f);
    *destRight = scaleToSInt8(rMotor, -1.0f, 1.0f);
}

SInt8 scaleToSInt8( float x, float domainMin, float domainMax)
{
    int rangeMin = -128;
    int rangeMax = 127;
    float result = rangeMin + (x-domainMin)/(domainMax-domainMin) * (rangeMax-rangeMin);
    return (SInt8)result;
}

- (void)balanceMotorBytesForLeftMotor:(SInt8)leftMotor 
                           rightMotor:(SInt8)rightMotor
                             destLeft:(SInt8 *)destLeft
                            destRight:(SInt8 *)destRight
{
    // DC motors usually will respond to identical voltages slightly differently.
    // In order to make them function roughly equally (i.e., steering straight
    // forward actually drives straight forward) apply the _leftRightMotorBalance
    // multiplier to the motors. 
    
    int correctedLeft = _last_leftMotor;
    int correctedRight = _last_rightMotor;
    
    correctedRight *= _leftRightMotorBalance;
    // If just applying the multiplier leaves the right side out of 
    // range, we should multiply the other side by _leftRightMotorBalance's
    // reciprocal so both values are OK.
    if (correctedRight > 127 || correctedRight < -128){
        correctedRight = _last_rightMotor;
        correctedLeft = (int)(_last_leftMotor * (1.0/_leftRightMotorBalance));
    }
    *destLeft = (SInt8)correctedLeft;
    *destRight = (SInt8)correctedRight;
}
#pragma mark R A D I O   C O M M A N D S
- (void)sendCommandToRobot:(NSDictionary *)commandDict;
{
    // ETJ DEBUG
    NSDictionary *actionTitlesDict = @{
                        kRMBOSpeakPhrase: @"Speak Phrase",
                        kRMBOMoveRobot: @"Move Robot",
                        kRMBOHeadTilt: @"Tilt Head",
                        kRMBODebugLogMessage: @"Debug Log Message",
                        kRMBOTurnInPlaceClockwise: @"Clockwise Turn",
                        kRMBOTurnInPlaceCounterClockwise: @"Counterclockwise Turn",
                        kRMBOStopRobotMovement: @"Stop Robot",
                        kRMBOChangeMood: @"Change Mood",
                    };
    NSLog( @"%@",(NSString *)actionTitlesDict[commandDict[@"command"]]);
    // END DEBUG */
    
    // Parse data to see if it should be sent to the iPod (eyes, sound) or Bluetooth board
    
    // TODO: as more actions are added, they should be categorized here. 
    NSArray *iPodCommands = @[kRMBOSpeakPhrase, kRMBOChangeMood, kRMBODebugLogMessage];
    //NSArray *btBoardCommands =  @[kRMBOMoveRobot, kRMBOHeadTilt, kRMBOTurnInPlaceClockwise,
    //                            kRMBOTurnInPlaceCounterClockwise, kRMBOStopRobotMovement];
                                
    // if we're talking to the iPod, use original method
    if (_isV6Hardware || [iPodCommands containsObject:commandDict[@"command"]]){
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:commandDict];
        [self sendDataToIPod:paramsData];
    }
    // Otherwise, we need to package our data for the Bluetooth board
    else{
        [self sendCommandToBTBoard:commandDict];
    }
                
}

- (void)sendCommandToBTBoard:(NSDictionary *)commandDict
{ 
    // Only send messages every 100 ms
    NSTimeInterval minMessageGap= 0.1;
    NSDate *curTime = [NSDate date];
    if ( [curTime timeIntervalSinceDate:_lastBTMessageTime] < minMessageGap){
        return;
    }
    
    NSString *command = commandDict[@"command"];
    
    if ([command isEqualToString:kRMBOTurnInPlaceClockwise]){
        // Let's say we turn at 50% speed
        _last_leftMotor = 64;
        _last_rightMotor = -64;
    }
    else if ([command isEqualToString:kRMBOTurnInPlaceCounterClockwise]){
        _last_leftMotor = -64;
        _last_rightMotor = 64;
    }
    else if ([command isEqualToString:kRMBOStopRobotMovement]){
        _last_leftMotor = 0;
        _last_rightMotor = 0;
    }
    else if ([command isEqualToString:kRMBOMoveRobot]){
        float x = [commandDict[@"x"] floatValue];
        float y = [commandDict[@"y"] floatValue];
        
        /*
        Reading from the analog stick may take some fixing to get it intuitively
        right. For now let's go with this. -ETJ 19 Aug 2014
        -- Y gives speed as portion of max/min speed. 
        -- X & Y choose desired direction, balance between motors
        */
        SInt8 l, r;
        [self motorStrengthsForAnalogStickX:x y:y destLeft:&l destRight:&r];
        _last_leftMotor = l;
        _last_rightMotor = r;

    }
    else if ([command isEqualToString:kRMBOHeadTilt]){
        // NOTE: Current (August 2014) versions of the Romibo hardware
        // don't include a left/right tilt servo, but the Romibo 
        // firmware does.  So... we don't set _last_tiltLeftRight
        // anywhere, but we could.  In which case we'd 
        // use two constants, kRMBOHeadTiltLeftRight & kRMBOHeadTiltForwardBack
        // and set those separately. -ETJ 20 Aug 2014
        
        float angle = [commandDict[@"angle"] floatValue];
        // FIXME: we should grab min and max from slider, not hardwired like here:
        
        _last_tiltForwardBack = (UInt8)((angle-60)/(120-60)* 255);
        
        // _last_tiltForwardBack = (UInt8)[commandDict[@"angle"] floatValue];
        // ETJ DEBUG
        NSLog(@"%@", commandDict[@"angle"]);
        NSLog(@"kRMBOHeadTiltForwardBack set to %d", _last_tiltForwardBack);
        // END DEBUG         
    }
    SInt8 balancedLeft, balancedRight;
    
    // Correct any difference between motors
    [self balanceMotorBytesForLeftMotor:_last_leftMotor
                             rightMotor:_last_rightMotor
                               destLeft: &balancedLeft
                              destRight: &balancedRight];
    
    // Generate a 4 byte string to be sent to BT board
    UInt32 commandBytes = [self commandBytesForLeftMotor:balancedLeft
                                              rightMotor:balancedRight
                                           leftRightTilt:_last_tiltLeftRight
                                         forwardBackTilt:_last_tiltForwardBack];
    
    // Don't resend a message identical to the last one sent
    if (commandBytes == _lastBTCommandBytes){ return;}
    // ETJ DEBUG
    UInt8 *cb = (UInt8 *)&commandBytes;
    NSLog(@"commandBytes:  %d %d %d %d", (SInt8)cb[0], (SInt8)cb[1], cb[2], cb[3]);
    // END DEBUG 
    
    _lastBTMessageTime = [NSDate date];
    _lastBTCommandBytes = commandBytes;
    [[ConnectionManager sharedInstance].connectedPeripheral writeValue:[NSData dataWithBytes:(void *)&commandBytes length:4]
                                                     forCharacteristic:[ConnectionManager sharedInstance].connectToTag.romibo_characteristic_write
                                                                  type:CBCharacteristicWriteWithResponse];        
}

- (void)sendDataToIPod:(NSData *)data
{
    NSError *error = nil;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    // TODO: add connection handling for BT board -ETJ 20 Aug 2014
    _connectedToRobot = YES;
    if (state == MCSessionStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_multipeerBrowser dismissViewControllerAnimated:YES completion:^{
                [self enableRobotControls];
            }];
            
        });
    }
    else {
        _connectedToRobot = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self disableRobotControls];
            [self endShowkitCall];
        });
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *command = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([command[@"command"] isEqualToString:kRMBODebugLogMessage]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@: %@", [peerID displayName], command[@"message"]);
        });
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress { }
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error { }
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID { }

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

- (void)enableRobotControls
{
    [self removeNotConnectedDisplay];
    [UIView animateWithDuration:0.8 animations:^{
        [_robotControls setAlpha:1.0];
        [_robotControls setUserInteractionEnabled:YES];
    }];
    
}

- (void)disableRobotControls
{
    [self showNotConnectedDisplay];
    [UIView animateWithDuration:0.8 animations:^{
        [_robotControls setAlpha:1.0];
        [_robotControls setUserInteractionEnabled:YES];
    }];
    
}

- (void)showNotConnectedDisplay
{
    [UIView animateWithDuration:0.3 animations:^{
        [_notConnectedLabel setAlpha:1.0];
        [_connectToRomiboButton setAlpha:1.0];
    }];
    [_connectToRomiboButton addTarget:self action:@selector(manageRobotConnection) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeNotConnectedDisplay
{
    [UIView animateWithDuration:0.3 animations:^{
        [_notConnectedLabel setAlpha:0.0];
        [_connectToRomiboButton setAlpha:0.0];
    }];
    [_connectToRomiboButton removeTarget:self action:@selector(manageRobotConnection) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)robotHeadTiltSliderAction:(id)sender
{
    [self tiltRobotHeadToAngle:_headTiltSlider.value];
}

typedef NS_ENUM(NSInteger, RMBOEyeMood) {
    RMBOEyeMood_Normal,
    RMBOEyeMood_Curious,
    RMBOEyeMood_Excited,
    RMBOEyeMood_Indifferent,
    RMBOEyeMood_Twitterpated,
    RMBOEyeBlink
};
#define NSV(val) [NSValue valueWithNonretainedObject:(val)]
- (IBAction)changeMood:(id)sender
{
    // Wrap buttons in NSValues since they don't conform to NSCopying
    NSDictionary *moodForButton = @{
        NSV(_curiousButton):         @(RMBOEyeMood_Curious),
        NSV(_excitedButton):         @(RMBOEyeMood_Excited),
        NSV(_indifferentButton):     @(RMBOEyeMood_Indifferent),
        NSV(_twitterpatedButton):    @(RMBOEyeMood_Twitterpated),
        NSV(_blinkButton):           @(RMBOEyeBlink)
    };
    NSNumber *mood = moodForButton[NSV(sender)];
    if (!mood){ return;}
    
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOChangeMood, @"mood" :mood };
        [self sendCommandToRobot:params];
    }
}



#pragma mark B L U E T O O T H   C O N N E C T I O N 

- (IBAction) addTagButtonPressed:(id)sender
{
    if(!self.isScanning)
    {
        [self startScanForTags];
    }
    else
    {
        [self stopScanForTags];
    }
    
}

- (void) startScanForTags
{
    NSLog(@"Starting scan for new tags...");
    [[ConnectionManager sharedInstance] startScanForTags];
    
    // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(addTagButtonPressed:)];
    
    self.isScanning = YES;
}

- (void) stopScanForTags
{
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTagButtonPressed:)];
    
    NSLog(@"Stopping scan for new tags.");
    
    
    [[ConnectionManager sharedInstance] stopScanForTags];
    self.isScanning = NO;
}

- (void) didUpdateData:(ProximityTag*)tag
{
    NSLog(@"RMBORobotControlViewController: didUpdateData called with tag %@",tag);    
//    self.connection_Label.text = tag.name;
    
}

- (void) didDiscoverTag:(ProximityTag*) tag
{
    NSLog(@"RMBORobotControlViewController: didDiscoverTag called with tag %@",tag);    
    tag.delegate = self;
    
}

- (void) didFailToConnect:(id)tag
{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"Failed to connect" message:[NSString stringWithFormat:@"The app couldn't connect to %@. \n\nThis usually indicates a previous bond. Go to the settings and clear it before you try again.", [tag name]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [dialog show];
    [self stopScanForTags];
}


- (void) isBluetoothEnabled:(bool)enabled
{
    NSLog(@"RMBORobotControlViewController: isBluetoothEnabled called with value %@",enabled?@"YES":@"NO");
    
    // [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

# pragma mark S H O W K I T
- (IBAction)showkitAction:(id)sender
{
    /*
    NSString* connectionStatus = [ShowKit getStateForKey:SHKConnectionStatusKey];
    if (![connectionStatus isEqualToString:SHKConnectionStatusInCall]) {
        [self initShowkitVideoCall];
    }
    else {
        [self endShowkitCall];
    }
     */
    
}

- (void)initShowkitVideoCall
{
    /*
    [_manageShowKitButton setHidden:YES];
    [_showkitActivityIndicator startAnimating];
     [ShowKit login:@"584.romibo_test_controller" password:@"iloverobots" withCompletionBlock:^(NSString *const connectionStatus) {
         NSLog(@"%@", connectionStatus);
         [ShowKit setState: SHKAudioInputModeMuted forKey: SHKAudioInputModeKey];
         [ShowKit setState:_remoteVideoView forKey:SHKMainDisplayViewKey];
         [ShowKit initiateCallWithSubscriber:@"584.romibo_test_client"];
     }];
     */
    
}

- (void)manageShowkitLogin
{
    /*
    NSString *connectionStatus = [ShowKit getStateForKey:SHKConnectionStatusKey];
    if ([connectionStatus isEqualToString:SHKConnectionStatusNotConnected]) {
        _showkitLoginAlertView = [[UIAlertView alloc] initWithTitle:@"Login into video sharing" message:@"Please enter your Romibo video sharing username and password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        [_showkitLoginAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [_showkitLoginAlertView setDelegate:self];
        [_showkitLoginAlertView show];
    }
    else {
        
    }
     */
}

- (void)endShowkitCall
{
    /*
    [ShowKit hangupCall];
    [_manageShowKitButton setHidden:NO];
    [_remoteVideoView setHidden:YES];
    [_remoteVideoView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [_manageShowKitButton setTitle:@"Turn on video streaming" forState:UIControlStateNormal];
     */
}

- (void)showkitStatusChanging:(NSNotification *)notification
{
    /*
    SHKNotification* showNotice ;
    NSString * value ;
    
    showNotice = (SHKNotification*) [notification object];
    value = (NSString*)showNotice.Value;
    //NSObject *error = showNotice.UserObject;

    if ([value isEqualToString:SHKConnectionStatusCallTerminated]){
    }
    else if ([value isEqualToString:SHKConnectionStatusInCall]) {
        [_remoteVideoView setAlpha:1.0];
        [_showkitActivityIndicator stopAnimating];
        [_manageShowKitButton setTitle:@"Stop video stream" forState:UIControlStateNormal];
        [_manageShowKitButton setHidden:NO];
        [ShowKit setState: SHKAudioInputModeMuted forKey: SHKAudioInputModeKey];
        [_remoteVideoView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    }
    else if ([value isEqualToString:SHKConnectionStatusLoggedIn]) {
        NSLog(@"logged");
    }
    else if ([value isEqualToString:SHKConnectionStatusNotConnected]) {
        NSLog(@"not connected");
    }
    else if ([value isEqualToString:SHKConnectionStatusLoginFailed]) {
        NSLog(@"login fail");
    }
    else if ([value isEqualToString:SHKConnectionStatusCallIncoming]) {
        NSLog(@"incomming call");
    }
    else if ([value isEqualToString:SHKConnectionStatusCallFailed]) {
        NSError *error = (NSError *)showNotice.UserObject;
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error starting video streaming" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_showkitActivityIndicator stopAnimating];
        [_manageShowKitButton setHidden:NO];
        [errorAlert show];
    }
     */
}



@end
