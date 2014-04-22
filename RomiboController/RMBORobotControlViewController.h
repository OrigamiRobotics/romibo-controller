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
//#import <ShowKit/ShowKit.h>
@class RMBOCategory;

@interface RMBORobotControlViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, MCBrowserViewControllerDelegate, RMBOActionDataSourceDelegate, UIAlertViewDelegate, JSAnalogueStickDelegate, MCSessionDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, weak) IBOutlet UIView *joyStickView;
@property (nonatomic, weak) IBOutlet UIView *headTiltView;
@property (nonatomic, strong) NSArray *fetchedCategories;
@property (nonatomic, weak) IBOutlet UICollectionView *cateogriesCollectionView;
@property (nonatomic, weak) IBOutlet UISlider *headTiltSlider;
@property (nonatomic, weak) IBOutlet UIButton *editorButton;
@property (nonatomic, weak) IBOutlet UICollectionView *tabCollectionView;
@property (nonatomic, strong) NSIndexPath *selectedTab;
@property (nonatomic, strong) UIPopoverController *menuPopoverController;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, assign) BOOL connectedToRobot;
@property (nonatomic, assign) BOOL loggedIntoShowkit;
@property (nonatomic, strong) MCBrowserViewController *multipeerBrowser;
@property (nonatomic, weak) IBOutlet UIView *robotControls;
@property (nonatomic, weak) IBOutlet UIView *remoteVideoView;
@property (nonatomic, weak) IBOutlet UILabel *notConnectedLabel;
@property (nonatomic, weak) IBOutlet UIButton *connectToRomiboButton;
@property (nonatomic, weak) IBOutlet UIButton *manageShowKitButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *showkitActivityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *happyButton;
@property (nonatomic, weak) IBOutlet UIButton *sadButton;
@property (nonatomic, weak) IBOutlet UIButton *excitedButton;
@property (nonatomic, weak) IBOutlet UIButton *confusedButton;
@property (nonatomic, weak) IBOutlet UIButton *blinkButton;

- (void)customizeViews;
- (void)loadEditorView;
- (IBAction)showMenuPopover:(id)sender;
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

- (void) reloadCategoriesAndActions;

@end
