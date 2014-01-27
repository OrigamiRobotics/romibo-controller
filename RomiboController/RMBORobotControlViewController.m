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

#define kRMBOMaxMutlipeerConnections 1
#define kRMBOConnectionMenuOption 1
#define kRMBOEditorMenuOption 0
#define kRMBOShowkitLoginOption 2
#define kRMBOServiceType @"origami-romibo"

#define kRMBOControlsDisabledAlpha 0.0

#define kRMBOMinimumMovementThreshold 0.125

//Commands
#define kRMBOSpeakPhrase @"kRMBOSpeakPhrase"
#define kRMBOMoveRobot @"kRMBOMoveRobot"
#define kRMBOHeadTilt @"kRMBOHeadTilt"
#define kRMBODebugLogMessage @"kRMBODebugLogMessage"
#define kRMBOTurnInPlaceClockwise @"kRMBOTurnInPlaceClockwise"
#define kRMBOTurnInPlaceCounterClockwise @"kRMBOTurnInPlaceCounterClockwise"
#define kRMBOStopRobotMovement @"kRMBOStopRobotMovement"

//Video
#define kRMBOShowkitAPIKey @"05070922-5868-4283-b21c-dfcf88a602ce"
#define kRMBOShowkitAccountNumber @"584"

//Pallets
#define kRMBOPalletTabDisabled 0.4

@interface RMBORobotControlViewController () {
    BOOL isShowingLandscapeView;
    NSInteger currentPage;
    BOOL isTurningClockwise;
    BOOL isTurningCounterclockwise;
}

- (void)orientationChanged:(NSNotification *)notification;
- (void)sendDataToRobot:(NSData *)data;
- (void)manageShowkitLogin;
- (void)initShowkitVideoCall;
- (void)endShowkitCall;
- (void)showkitStatusChanging:(NSNotification *)notification;
- (void)showNotConnectedDisplay;
- (void)removeNotConnectedDisplay;
- (void)turnRobotClockwise:(id)sender;
- (void)turnRobotCounterClockwise:(id)sender;

@property (nonatomic, strong) UIAlertView *showkitLoginAlertView;
@property (nonatomic, strong) NSTimer *turningTimer;
@property (nonatomic, assign) float lastX;
@property (nonatomic, assign) float lastY;

@end

@implementation RMBORobotControlViewController

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
        AppDelegate *del = [[UIApplication sharedApplication] delegate];
        _mainContext = [del managedObjectContext];
        currentPage = 0;
    }
    
    [self customizeViews];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showkitStatusChanging:)
     name:SHKConnectionStatusChangedNotification
     object:nil];
    _lastX = 0.0;
    _lastY = 0.0;
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
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
    _headTiltSlider.transform = trans;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeViews
{
    [self.view setBackgroundColor:[UIColor rmbo_blueStarBackground]];
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
    vc = [[RMBOPopoverMenuViewController alloc] initWithStyle:UITableViewStyleGrouped romiboConnected:_connectedToRobot showkitLoggedIn:_loggedIntoShowkit];
    [vc.tableView setDelegate:self];
    
    _menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    [_menuPopoverController setPopoverContentSize:CGSizeMake(320, 250)];
    [_menuPopoverController presentPopoverFromRect:[_editorButton frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
        NSInteger newPage = scrollView.contentOffset.x / scrollView.frame.size.width;
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
            NSInteger newPage = scrollView.contentOffset.x / scrollView.frame.size.width;
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
    if ([indexPath row] == kRMBOConnectionMenuOption) {
        [self manageRobotConnection];
    }
    else if ([indexPath row] == kRMBOEditorMenuOption) {
        [self loadEditorView];
    }
    else if ([indexPath row] == kRMBOShowkitLoginOption) {
        [self manageShowkitLogin];
    }
}

- (void)manageRobotConnection
{
    if (!_connectedToRobot) {
        _multipeerBrowser = [[MCBrowserViewController alloc] initWithServiceType:kRMBOServiceType session:_session];
        [_multipeerBrowser setMaximumNumberOfPeers:kRMBOMaxMutlipeerConnections];
        [_multipeerBrowser setDelegate:self];
        [self presentViewController:_multipeerBrowser animated:YES completion:nil];
    }
    else {
        UIAlertView *disconnectView = [[UIAlertView alloc] initWithTitle:@"Disconnect from Robot?" message:@"Are you sure you want to disconect from the robot?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disconnect", nil];
        [disconnectView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_showkitLoginAlertView]) {
        if (buttonIndex == 1) {
            [ShowKit login:[NSString stringWithFormat:@"%@.%@", kRMBOShowkitAccountNumber, [[alertView textFieldAtIndex:0] text]]
                  password:[[alertView textFieldAtIndex:1] text]
       withCompletionBlock:^(NSString *const connectionStatus) {
                NSLog(@"%@", connectionStatus);
                [UIView animateWithDuration:0.4 animations:^{
                    [_manageShowKitButton setAlpha:1.0];
                }];
            }];
        }
    }
    else {
        if (buttonIndex == 1) {
            [_session disconnect];
            _connectedToRobot = NO;
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
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        
        [self sendDataToRobot:paramsData];
    }
}

- (void)moveRobotWithX:(CGFloat)xValue andY:(CGFloat)yValue
{
    if (_connectedToRobot) {
        
        CGFloat xCheck = fabs(_lastX - xValue);
        CGFloat yCheck = fabs(_lastY - yValue);
        
        if (xCheck >= kRMBOMinimumMovementThreshold || yCheck >= kRMBOMinimumMovementThreshold) {
            NSLog(@"moving robot");
            NSDictionary *params = @{@"command" : kRMBOMoveRobot, @"x" : [NSNumber numberWithFloat:xValue], @"y" : [NSNumber numberWithFloat:yValue]};
            NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
            
            [self sendDataToRobot:paramsData];
            _lastX = xValue;
            _lastY = yValue;
        }
    }
}

- (void)stopRobotMovement
{
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOStopRobotMovement, @"timestamp" : [NSDate date]};
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        
        [self sendDataToRobot:paramsData];
    }
}

- (void)tiltRobotHeadToAngle:(CGFloat)angle
{
    if (_connectedToRobot) {
        NSDictionary *params = @{@"command" : kRMBOHeadTilt, @"angle" : [NSNumber numberWithFloat:angle]};
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        
        [self sendDataToRobot:paramsData];
    }
}

- (void)turnRobotClockwise:(id)sender
{
    if (_connectedToRobot && isTurningClockwise) {
        NSDictionary *params = @{@"command" : kRMBOTurnInPlaceClockwise, @"timestamp" : [NSDate date]};
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        [self sendDataToRobot:paramsData];
    }
}

- (void)turnRobotCounterClockwise:(id)sender
{
    if (_connectedToRobot && isTurningCounterclockwise) {
        NSDictionary *params = @{@"command" : kRMBOTurnInPlaceCounterClockwise, @"timestamp" : [NSDate date]};
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        [self sendDataToRobot:paramsData];
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

- (void)sendDataToRobot:(NSData *)data
{
    NSError *error = nil;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick
{
    [self moveRobotWithX:analogueStick.xValue andY:analogueStick.yValue];
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
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
        [_robotControls setAlpha:kRMBOControlsDisabledAlpha];
        [_robotControls setUserInteractionEnabled:NO];
    }];
    
}

- (IBAction)showkitAction:(id)sender
{
    NSString* connectionStatus = [ShowKit getStateForKey:SHKConnectionStatusKey];
    if (![connectionStatus isEqualToString:SHKConnectionStatusInCall]) {
        [self initShowkitVideoCall];
    }
    else {
        [self endShowkitCall];
    }
    
}

- (void)initShowkitVideoCall
{
    [_manageShowKitButton setHidden:YES];
    [_showkitActivityIndicator startAnimating];
     [ShowKit login:@"584.romibo_test_controller" password:@"iloverobots" withCompletionBlock:^(NSString *const connectionStatus) {
         NSLog(@"%@", connectionStatus);
         [ShowKit setState: SHKAudioInputModeMuted forKey: SHKAudioInputModeKey];
         [ShowKit setState:_remoteVideoView forKey:SHKMainDisplayViewKey];
         [ShowKit initiateCallWithSubscriber:@"584.romibo_test_client"];
     }];
    
}

- (void)manageShowkitLogin
{
    NSString *connectionStatus = [ShowKit getStateForKey:SHKConnectionStatusKey];
    if ([connectionStatus isEqualToString:SHKConnectionStatusNotConnected]) {
        _showkitLoginAlertView = [[UIAlertView alloc] initWithTitle:@"Login into video sharing" message:@"Please enter your Romibo video sharing username and password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        [_showkitLoginAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [_showkitLoginAlertView setDelegate:self];
        [_showkitLoginAlertView show];
    }
    else {
        
    }
}

- (void)endShowkitCall
{
    [ShowKit hangupCall];
    [_manageShowKitButton setHidden:NO];
    [_remoteVideoView setHidden:YES];
    [_remoteVideoView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [_manageShowKitButton setTitle:@"Turn on video streaming" forState:UIControlStateNormal];
}

- (void)showkitStatusChanging:(NSNotification *)notification
{
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










@end
