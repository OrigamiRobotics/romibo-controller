//
//  RMBOCategoryEditorViewController.m
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOCategoryEditorViewController.h"
#import "RMBOCategory.h"
#import "RMBOAction.h"
#import "RMBOButtonCell.h"
#import "UIImage+RMBOTintImage.h"

#define RMBOColorPickerWidth 320.0f
#define RMBOColorPickerHeight 200
#define RMBOAnimationLength 0.3



@interface RMBOCategoryEditorViewController ()

@property (nonatomic, assign) NSInteger currentTag;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL isDeleting;
@property (nonatomic, assign) RMBOCurrentColorPicker currentColorPicker;

- (UIImageView *)glowImageView;

@end

@implementation RMBOCategoryEditorViewController

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
	
    UIImage *bannerImage = [UIImage imageNamed:@"rmtoolbarLogo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bannerImage];
    self.navigationItem.titleView = imageView;
    
    [self loadActionsFromPersistentStore];
    [_editorView setAlpha:0.0];
    [_categoryNameField setText:[_category name]];
    
    [_speechSlider setMinimumValue:AVSpeechUtteranceMinimumSpeechRate];
    [_speechSlider setMaximumValue:AVSpeechUtteranceMaximumSpeechRate];
    
    [_dataSource setCollectionView:_buttonCollectionView];
    
    [self customizeViews];
    [self updateNoEditorInstructionLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_isDeleting) {
       [_category setPreview:[self generatePreviewImage]];
    }
    else {
        _isDeleting = YES;
    }
    NSError *error;
    [_mainContext save:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeViews
{
    [[_buttonCollectionView layer] setCornerRadius:6.0];
    [[_buttonCollectionView layer] setBorderWidth:1.0];
    [[_buttonCollectionView layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_paletteColorButton layer] setBorderWidth:1.0f];
    [[_paletteColorButton layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_categoryNameField layer] setBorderWidth:1.0f];
    [[_categoryNameField layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_buttonColorButton layer] setBorderWidth:1.0f];
    [[_buttonColorButton layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_buttonTitleField layer] setCornerRadius:6.0];
    [[_buttonTitleField layer] setBorderWidth:1.0];
    [[_buttonTitleField layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_buttonTextColorButton layer] setBorderWidth:1.0f];
    [[_buttonTextColorButton layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [[_speechField layer] setBorderWidth:1.0f];
    [[_speechField layer] setCornerRadius:6.0];
    [[_speechField layer] setBorderColor:[[UIColor rmbo_greyBorderColor] CGColor]];
    
    [_paletteColorButton setBackgroundColor:_category.pageColor];
    

}

- (void)loadActionsFromPersistentStore
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Action" inManagedObjectContext:_mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@", _category];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"threeBasedIndex" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSArray *buttonsFixed = [_mainContext executeFetchRequest:request error:&error];
    
    _dataSource.fetchedButtons = [NSMutableArray arrayWithArray:buttonsFixed];
    
    [_buttonCollectionView reloadData];
    
}

- (IBAction)createNewButtonAction:(id)sender
{
    RMBOAction *action = [NSEntityDescription insertNewObjectForEntityForName:@"Action" inManagedObjectContext:_mainContext];
    
    [action setCategory:_category];
    
    [action setThreeBasedIndex:[NSNumber numberWithInteger:_dataSource.fetchedButtons.count + 1]];

    [action setSpeechPhrase:@""];
    [action setButtonTitle:@"New Action"];
    [action setSpeachSpeedRate:[NSNumber numberWithFloat:0.5f]];
    
    [action setButtonColor:[UIColor rmbo_turquoiseColor]];
    [action setButtonTitleColor:[UIColor blackColor]];
    

    [_dataSource addActionToFetchedActions:action];
    
    [_buttonCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataSource.fetchedButtons.count -1 inSection:0]]];
    
    //[self loadActionsFromPersistentStore];
    
    if (_currentIndexPath) {
        RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:_currentIndexPath];
        //[cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:nil];
    }
    
    _currentIndexPath = [NSIndexPath indexPathForItem:_dataSource.fetchedButtons.count -1 inSection:0];
    
    [_editorView setHidden:NO];
    
    action = [[_dataSource fetchedButtons] objectAtIndex:[_currentIndexPath item]];
    
    [_buttonTitleField setText:[action buttonTitle]];
    [_speechField setText:[action speechPhrase]];
    [_buttonColorButton setBackgroundColor:[action buttonColor]];
    [_buttonTextColorButton setBackgroundColor:[action buttonTitleColor]];
    [_speechSlider setValue:action.speachSpeedRate.floatValue];
    
    [self presentButtonEditor];

    [_buttonCollectionView selectItemAtIndexPath:_currentIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    
    if ([[_buttonCollectionView indexPathsForSelectedItems] count] == 1) {
        RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:_buttonCollectionView.indexPathsForSelectedItems[0]];
        //[cell setBackgroundColor:[UIColor yellowColor]];
        [cell setBackgroundView:[self glowImageView]];
    }
    
    
}

- (IBAction)buttonSelectedForEditingAction:(id)sender
{
    /*
    if (_currentTag >= 0) {
        RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentTag inSection:0]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    _currentTag = [sender tag];
    
    [_editorView setHidden:NO];
    
    RMBOAction *action = [[_dataSource fetchedButtons] objectAtIndex:_currentTag];
    
    [_buttonTitleField setText:[action buttonTitle]];
    [_speechField setText:[action speechPhrase]];
    [_buttonColorButton setBackgroundColor:[action buttonColor]];
    [_buttonTextColorButton setBackgroundColor:[action buttonTitleColor]];
    [_speechSlider setValue:action.speachSpeedRate.floatValue];
    
    [self presentButtonEditor];
    
    RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentTag inSection:0]];
    [cell setBackgroundColor:[UIColor yellowColor]];
    _currentTag = [sender tag];
     */
    
}

- (IBAction)updateTitleField:(id)sender
{
    RMBOAction *action = [_dataSource fetchedButtons][_currentIndexPath.item];
    [action setButtonTitle:[_buttonTitleField text]];
    [_buttonCollectionView reloadItemsAtIndexPaths:@[_currentIndexPath]];
    
    RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:_currentIndexPath];
    //[cell setBackgroundColor:[UIColor yellowColor]];
    [cell setBackgroundView:[self glowImageView]];
}

- (IBAction)updateCategoryField:(id)sender
{
    [_category setName:[_categoryNameField text]];
}

- (IBAction)selectColor:(id)sender
{
    
}

 -(void)setupColorPopover
{
    if (!_popover) {
        RMBOColorPickerViewController *vc = [[RMBOColorPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        [vc setColorPickerDelegate:self];
        _popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [_popover setPopoverContentSize:CGSizeMake(RMBOColorPickerWidth, RMBOColorPickerHeight)];
    }
}

- (IBAction)updateButtonColorAction:(id)sender
{
    [self setupColorPopover];
    [_popover presentPopoverFromRect:[_buttonColorButton bounds] inView:_buttonColorButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _currentColorPicker = RMBOButtonBackgroundColor;
}

- (IBAction)updateButtonTextColorAction:(id)sender
{
    [self setupColorPopover];
    [_popover presentPopoverFromRect:[_buttonTextColorButton bounds] inView:_buttonTextColorButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _currentColorPicker = RMBOButtonTextColor;
}

- (void)userDidPickColor:(UIColor *)color fromPicker:(id)sender
{
    [_popover dismissPopoverAnimated:YES];
    RMBOAction *action = nil;
    if (_currentColorPicker == RMBOButtonBackgroundColor) {
        action = [_dataSource fetchedButtons][_currentIndexPath.item];
        [action setButtonColor:color];
        [_buttonColorButton setBackgroundColor:color];
        [_buttonCollectionView reloadItemsAtIndexPaths:@[_currentIndexPath]];
    }
    else if (_currentColorPicker == RMBOButtonTextColor){
        action = [_dataSource fetchedButtons][_currentIndexPath.item];
        [action setButtonTitleColor:color];
        [_buttonTextColorButton setBackgroundColor:color];
        [_buttonCollectionView reloadItemsAtIndexPaths:@[_currentIndexPath]];
    }
    else {
        [_category setPageColor:color];
        [_paletteColorButton setBackgroundColor:color];
    }
}

- (IBAction)deleteButtonAction:(id)sender
{
    if (!_buttonDeleteAlertView) {
        _buttonDeleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Button" message:@"Are you sure you want to delete this button from this category?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [_buttonDeleteAlertView setDelegate:self];
    }
    
    [_buttonDeleteAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_buttonDeleteAlertView]) {
        if (buttonIndex == 1) {
            [self deleteButtonFromPersistentStore];
        }
    }
    else if ([alertView isEqual:_paletteDeleteAlertView]) {
        if (buttonIndex == 1) {
            [self deletePalette];
        }
    }
}

- (void)deleteButtonFromPersistentStore
{
    RMBOAction *action = [_dataSource fetchedButtons][_currentIndexPath.item];
    [_mainContext deleteObject:action];
        
    [self loadActionsFromPersistentStore];
    
    [self dismissButtonEditor];
}

- (void)presentButtonEditor
{
    [UIView animateWithDuration: RMBOAnimationLength animations:^{
        [_editorView setAlpha:1.0];
    }];
}
- (void)dismissButtonEditor
{
    [self updateNoEditorInstructionLabel];
    [UIView animateWithDuration:RMBOAnimationLength animations:^{
        [_editorView setAlpha:0.0];
    }];
}

- (void)updateNoEditorInstructionLabel
{
    if ([[_dataSource fetchedButtons] count] == 0) {
        [_noEditorInstructionLabel setText:@"No buttons have been added to this category yet. Tap Add New Button to add a button to this category"];
    }
    else {
        [_noEditorInstructionLabel setText:@"Tap a button in your category to edit it."];
    }
}

- (IBAction)previewSpeechAction:(id)sender
{
    if (!_speechSynth) {
        _speechSynth = [[AVSpeechSynthesizer alloc] init];
        [_speechSynth setDelegate:self];
    }
    
    RMBOAction *action = [_dataSource fetchedButtons][_currentIndexPath.item];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[action speechPhrase]];
    [utterance setRate:action.speachSpeedRate.floatValue];
    [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
    [_previewButton setEnabled:NO];
    [_speechSynth speakUtterance:utterance];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [_previewButton setEnabled:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    RMBOAction *action = [_dataSource fetchedButtons][_currentIndexPath.item];
    [action setSpeechPhrase:[_speechField text]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (NSData *)generatePreviewImage
{
    UIGraphicsBeginImageContextWithOptions(_buttonCollectionView.bounds.size, _buttonCollectionView.opaque, 0.0);
    [_buttonCollectionView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

- (IBAction)deletePaletteAction:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"Delete %@", [_category name]];
    NSString *message = [NSString stringWithFormat:@"Are you sure want to delete %@?", [_category name]];
    
    _paletteDeleteAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [_paletteDeleteAlertView show];
}

- (void)deletePalette
{
    [_mainContext deleteObject:_category];
    _isDeleting = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updatePalletColorAction:(id)sender
{
    [self setupColorPopover];
    [_popover presentPopoverFromRect:[_paletteColorButton bounds] inView:_paletteColorButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _currentColorPicker = RMBOPaletteColor;
    
}

- (IBAction)speechSliderRateChanged:(id)sender
{
    RMBOAction *action = [_dataSource fetchedButtons][_currentIndexPath.item];
    [action setSpeachSpeedRate:[NSNumber numberWithFloat:[_speechSlider value]]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_buttonTitleField]) {
        [_speechField becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
    }
    
    return NO;
}

- (void)cellIsBeingMovedInDataSource:(RMBOActionDataSource *)dataSource
{
    [self dismissButtonEditor];
}

- (void)cellDoneBeingMovedInDataSource:(RMBOActionDataSource *)dataSource
{
    [_buttonCollectionView reloadData];
}

- (void)actionDataSource:(RMBOActionDataSource *)dataSource userSelectedButton:(id)sender atIndexPath:(NSIndexPath *)indexPath withAction:(RMBOAction *)action
{
    
    if (_currentIndexPath) {
        RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:_currentIndexPath];
        //[cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:nil];
    }
    
    _currentIndexPath = indexPath;
    
    [_editorView setHidden:NO];
    
    [_buttonTitleField setText:[action buttonTitle]];
    [_speechField setText:[action speechPhrase]];
    [_buttonColorButton setBackgroundColor:[action buttonColor]];
    [_buttonTextColorButton setBackgroundColor:[action buttonTitleColor]];
    [_speechSlider setValue:action.speachSpeedRate.floatValue];
    
    [self presentButtonEditor];
    
    RMBOButtonCell *cell = (RMBOButtonCell *)[_buttonCollectionView cellForItemAtIndexPath:indexPath];
    //[cell setBackgroundColor:[UIColor yellowColor]];
    [cell setBackgroundView:[self glowImageView]];
}

- (UIImageView *)glowImageView
{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glowback"]];
    [iv setFrame:CGRectMake(0, 0, 170, 60)];
    return iv;
}

- (IBAction)sendPalletAction:(id)sender
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Email not setup" message:@"In order to send pallets, you must setup your iPad's email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [error show];
        return;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_category.dictionaryRepresentation options:0 error:&error];
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    NSData *stringData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:@"Romibo Pallet"];
    
    NSString *timeInterval = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    timeInterval = [timeInterval stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@.rmbo", [[_category name] stringByReplacingOccurrencesOfString:@" " withString:@""], timeInterval];
    
    [mc addAttachmentData:stringData mimeType:@"text/plain" fileName:fileName];
    
    [mc setMailComposeDelegate:self];
    
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
