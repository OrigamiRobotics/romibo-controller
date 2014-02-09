//
//  RMBOCategoryEditorViewController.h
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RMBOColorPickerViewController.h"
#import "UIColor+RMBOColors.h"
#import "RMBOActionDataSource.h"
@import AVFoundation;
@import MessageUI;

@class RMBOCategory;

typedef NS_ENUM(NSInteger, RMBOCurrentColorPicker) {
    RMBOPaletteColor,
    RMBOButtonBackgroundColor,
    RMBOButtonTextColor
};

@interface RMBOCategoryEditorViewController : UIViewController <UICollectionViewDelegate, RMBOColorPickerDelegate, UIAlertViewDelegate, AVSpeechSynthesizerDelegate, UITextViewDelegate, UITextFieldDelegate, RMBOActionDataSourceDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) RMBOCategory *category;
@property (nonatomic, weak) IBOutlet RMBOActionDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UICollectionView *buttonCollectionView;
@property (nonatomic, weak) IBOutlet UITextField *categoryNameField;
@property (nonatomic, weak) IBOutlet UIView *editorView;
@property (nonatomic, weak) IBOutlet UITextField *buttonTitleField;
@property (nonatomic, weak) IBOutlet UITextView *speechField;
@property (nonatomic, weak) IBOutlet UIButton *buttonColorButton;
@property (nonatomic, weak) IBOutlet UIButton *buttonTextColorButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteActionButtonButton;
@property (nonatomic, weak) IBOutlet UIButton *paletteColorButton;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UIAlertView *buttonDeleteAlertView;
@property (nonatomic, strong) UIAlertView *paletteDeleteAlertView;
@property (nonatomic, weak) IBOutlet UILabel *noEditorInstructionLabel;
@property (nonatomic, weak) IBOutlet UIButton *previewButton;
@property (nonatomic, weak) IBOutlet UISlider *speechSlider;

@property (nonatomic, strong) AVSpeechSynthesizer *speechSynth;

- (void)customizeViews;
- (void)loadActionsFromPersistentStore;
- (IBAction)createNewButtonAction:(id)sender;
- (IBAction)buttonSelectedForEditingAction:(id)sender;
- (IBAction)updateTitleField:(id)sender;
- (IBAction)updateCategoryField:(id)sender;
- (void)setupColorPopover;
- (IBAction)updateButtonColorAction:(id)sender;
- (IBAction)updateButtonTextColorAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;
- (void)deleteButtonFromPersistentStore;
- (void)presentButtonEditor;
- (void)dismissButtonEditor;
- (void)updateNoEditorInstructionLabel;
- (IBAction)previewSpeechAction:(id)sender;
- (NSData *)generatePreviewImage;
- (IBAction)deletePaletteAction:(id)sender;
- (void)deletePalette;
- (IBAction)updatePalletColorAction:(id)sender;
- (IBAction)speechSliderRateChanged:(id)sender;
- (IBAction)sendPalletAction:(id)sender;

@end
