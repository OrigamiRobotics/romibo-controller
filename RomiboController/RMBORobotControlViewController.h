//
//  ControllerViewController.h
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "RMBOButtonCell.h"
#import "RMBOActionDataSource.h"
#import "JSAnalogueStick.h"
#import <QuartzCore/QuartzCore.h>
#import "Bluetooth_LE/ConnectionManager.h"

//#import <ShowKit/ShowKit.h>
@class RMBOCategory;

@interface RMBORobotControlViewController : UIViewController <UICollectionViewDataSource, 
                                            UICollectionViewDelegate, UITableViewDelegate, 
                                            MCBrowserViewControllerDelegate, RMBOActionDataSourceDelegate, 
                                            UIAlertViewDelegate, JSAnalogueStickDelegate, MCSessionDelegate, 
                                            UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIAlertViewDelegate,
                                            ConnectionManagerDelegate>
{

    BOOL isShowingLandscapeView;
    NSUInteger currentPage;
    BOOL isTurningClockwise;
    BOOL isTurningCounterclockwise;
    
}

@property (nonatomic, weak) IBOutlet UIView *joyStickView;
@property (nonatomic, weak) IBOutlet UIView *headTiltView;
@property (nonatomic, weak) IBOutlet UICollectionView *cateogriesCollectionView;
@property (nonatomic, weak) IBOutlet UISlider *headTiltSlider;
@property (nonatomic, weak) IBOutlet UIButton *editorButton;
@property (nonatomic, weak) IBOutlet UICollectionView *tabCollectionView;
@property (nonatomic, weak) IBOutlet UIView *robotControls;
@property (nonatomic, weak) IBOutlet UIView *remoteVideoView;
@property (nonatomic, weak) IBOutlet UILabel *notConnectedLabel;
@property (nonatomic, weak) IBOutlet UIButton *connectToRomiboButton;
@property (nonatomic, weak) IBOutlet UIButton *manageShowKitButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *showkitActivityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *curiousButton;
@property (nonatomic, weak) IBOutlet UIButton *excitedButton;
@property (nonatomic, weak) IBOutlet UIButton *indifferentButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterpatedButton;
@property (nonatomic, weak) IBOutlet UIButton *blinkButton;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSIndexPath *selectedTab;
@property (nonatomic, strong) UIPopoverController *menuPopoverController;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, assign) BOOL connectedToRobot;
@property (nonatomic, assign) BOOL loggedIntoShowkit;
@property (nonatomic, strong) MCBrowserViewController *multipeerBrowser;
@property (nonatomic, strong) NSArray *fetchedCategories;
@property (nonatomic, strong) UIAlertView *showkitLoginAlertView;
@property (nonatomic, strong) NSTimer *turningTimer;
@property (nonatomic, assign) CGFloat lastX;
@property (nonatomic, assign) CGFloat lastY;
// Bluetooth connection
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, strong) NSDate *lastBTMessageTime;
@property (nonatomic, assign) UInt32 lastBTCommandBytes;

    
    
// Hardware state
@property SInt8 last_leftMotor;         
@property SInt8 last_rightMotor;        
@property UInt8 last_tiltLeftRight;
@property UInt8 last_tiltForwardBack;
@property float leftRightMotorBalance;

@property (nonatomic, assign) BOOL isV6Hardware;


- (void)customizeViews;
- (void)loadEditorView;
- (IBAction)showMenuPopover:(id)sender;
- (BOOL)detectV6Hardware;
- (void)loadCategoriesFromPersistentStore;
- (NSArray *)loadActionsFromPersistentStoreWithCateogry:(RMBOCategory *)category;
- (void)manageRobotConnection;
- (void)sendSpeechPhraseToRobot:(NSString *)phrase atSpeechRate:(float)speechRate;
- (void)moveRobotWithX:(CGFloat)xValue andY:(CGFloat)yValue;
- (void)stopRobotMovement;
- (void)tiltRobotHeadToAngle:(CGFloat)angle;
- (void)enableRobotControls;
- (void)disableRobotControls;
- (IBAction)showkitAction:(id)sender;
- (IBAction)robotHeadTiltSliderAction:(id)sender;
- (IBAction)beginTurnRobotInPlaceClockwiseAction:(id)sender;
- (IBAction)beginTurnRobotInPlaceCounterClockwiseAction:(id)sender;
- (IBAction)endTurnRobotInPlaceClockwiseAction:(id)sender;
- (IBAction)endTurnRobotInPlaceCounterClockwiseAction:(id)sender;
- (IBAction)changeMood:(id)sender;

- (void)orientationChanged:(NSNotification *)notification;
- (void)sendCommandToRobot:(NSDictionary *)commandDict;
- (void)sendDataToIPod:(NSData *)data;
- (void)manageShowkitLogin;
- (void)initShowkitVideoCall;
- (void)endShowkitCall;
- (void)showkitStatusChanging:(NSNotification *)notification;
- (void)showNotConnectedDisplay;
- (void)removeNotConnectedDisplay;
- (void)turnRobotClockwise:(id)sender;
- (void)turnRobotCounterClockwise:(id)sender;

- (void) reloadCategoriesAndActions;

// Required by ConnectionManagerDelegate protocol for BluetoothLE
- (void) isBluetoothEnabled:(bool) enabled;
- (void) didDiscoverTag:(ProximityTag*) tag;

@end


