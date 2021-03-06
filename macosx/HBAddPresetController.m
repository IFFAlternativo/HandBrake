//
//  HBAddPresetController.m
//  HandBrake
//
//  Created by Damiano Galassi on 23/11/14.
//
//

#import "HBAddPresetController.h"
#import "HBPreset.h"
#import "HBMutablePreset.h"

@interface HBAddPresetController ()

@property (unsafe_unretained) IBOutlet NSTextField *name;
@property (unsafe_unretained) IBOutlet NSTextField *desc;

@property (unsafe_unretained) IBOutlet NSPopUpButton *picSettingsPopUp;
@property (unsafe_unretained) IBOutlet NSTextField *picWidth;
@property (unsafe_unretained) IBOutlet NSTextField *picHeight;
@property (unsafe_unretained) IBOutlet NSBox *picWidthHeightBox;

@property (nonatomic, strong) HBPreset *preset;
@property NSSize size;

@end

@implementation HBAddPresetController

- (instancetype)initWithPreset:(HBPreset *)preset videoSize:(NSSize)size;
{
    self = [super initWithWindowNibName:@"AddPreset"];
    if (self)
    {
        NSParameterAssert(preset);
        _preset = preset;
        _size = size;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    /*
     * Populate the preset picture settings popup.
     *
     * Custom is not applicable when the anamorphic mode is Strict.
     *
     * Use [NSMenuItem tag] to store preset values for each option.
     */
    [self.picSettingsPopUp addItemWithTitle:NSLocalizedString(@"None", @"")];
    [[self.picSettingsPopUp lastItem] setTag: 0];

    if (![self.preset[@"PicturePAR"] isEqualToString:@"strict"])
    {
        // not Strict, Custom is applicable
        [self.picSettingsPopUp addItemWithTitle:NSLocalizedString(@"Custom", @"")];
        [[self.picSettingsPopUp lastItem] setTag: 1];
    }
    [self.picSettingsPopUp addItemWithTitle:NSLocalizedString(@"Source Maximum (post source scan)", @"")];
    [[self.picSettingsPopUp lastItem] setTag: 2];

    //Default to Source Maximum
    [self.picSettingsPopUp selectItemWithTag:2];

    /* Initialize custom height and width settings to current values */
    [self.picWidth setStringValue: [NSString stringWithFormat:@"%d", (int)self.size.width]];
    [self.picHeight setStringValue: [NSString stringWithFormat:@"%d",(int)self.size.height]];
    [self addPresetPicDropdownChanged:nil];
}

- (IBAction)addPresetPicDropdownChanged:(id)sender
{
    if (self.picSettingsPopUp.selectedItem.tag == 1)
    {
        self.picWidthHeightBox.hidden = NO;
    }
    else
    {
        self.picWidthHeightBox.hidden = YES;
    }
}

- (IBAction)add:(id)sender
{
    if (self.name.stringValue.length == 0)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"The preset name cannot be empty.", @"")];
        [alert setInformativeText:NSLocalizedString(@"Please enter a name.", @"")];
        [alert runModal];
    }
    else
    {
        HBMutablePreset *newPreset = [self.preset mutableCopy];

        newPreset.name = self.name.stringValue;
        newPreset.presetDescription = self.desc.stringValue;

        // Get the picture size
        newPreset[@"PictureWidth"] = @(self.picWidth.integerValue);
        newPreset[@"PictureHeight"] = @(self.picHeight.integerValue);

        //Get the whether or not to apply pic Size and Cropping (includes Anamorphic)
        newPreset[@"UsesPictureSettings"] = @(self.picSettingsPopUp.selectedItem.tag);

        // Always use Picture Filter settings for the preset
        newPreset[@"UsesPictureFilters"] = @YES;

        [newPreset cleanUp];

        self.preset = [newPreset copy];

        [[self window] orderOut:nil];
        [NSApp endSheet:[self window] returnCode:NSModalResponseContinue];
    }
}

- (IBAction)cancel:(id)sender
{
    [[self window] orderOut:nil];
    [NSApp endSheet:[self window] returnCode:NSModalResponseAbort];
}

@end
