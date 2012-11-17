//
//  AppDelegate.h
//  FreeboxMiniRemote
//
//  Created by Bertrand Boudaud on 04/07/12.
//  Copyright (c) 2012 Bertrand Boudaud. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate,NSTextFieldDelegate,NSWindowDelegate>
{
   __weak NSSearchField *  searchTextField;
   IBOutlet NSMenu *       statusMenu;
   IBOutlet NSView *       mainMenuItem;
   NSStatusItem *          statusItem;
}

@property NSMutableArray      *channels;
@property NSMutableArray      *filteredChannels;
@property NSMutableArray      *filteredChannelsMenuItems;
@property NSMutableArray      *pendingCommands;
@property NSString            *currentCommand;
@property bool                showMenuOnActivation;
@property NSInvocation        *updateMenuInvocation;
@property NSTimer             *updateTimer;
@property int                 nbMaxFilteredItems;
@property NSMenuItem          *selectedMenuItem;
@property unsigned long       selectedMenuItemIndex;
@property NSMutableDictionary *options;

- (IBAction)button1:(id)sender;
- (IBAction)button2:(id)sender;
- (IBAction)button3:(id)sender;
- (IBAction)button4:(id)sender;
- (IBAction)button5:(id)sender;
- (IBAction)button6:(id)sender;
- (IBAction)button7:(id)sender;
- (IBAction)button8:(id)sender;
- (IBAction)button9:(id)sender;
- (IBAction)button0:(id)sender;
- (IBAction)buttonBwd:(id)sender;
- (IBAction)buttonFwd:(id)sender;
- (IBAction)buttonRec:(id)sender;
- (IBAction)buttonPlay:(id)sender;
- (IBAction)buttonPGMinus:(id)sender;
- (IBAction)buttonPGPlus:(id)sender;
- (IBAction)buttonVolPlus:(id)sender;
- (IBAction)buttonVolMinus:(id)sender;
- (IBAction)buttonOptions:(id)sender;
- (IBAction)buttonMute:(id)sender;
- (IBAction)buttonPower:(id)sender;
- (IBAction)buttonUp:(id)sender;
- (IBAction)buttonDown:(id)sender;
- (IBAction)buttonLeft:(id)sender;
- (IBAction)buttonRight:(id)sender;
- (IBAction)buttonRed:(id)sender;
- (IBAction)buttonGreen:(id)sender;
- (IBAction)buttonBlue:(id)sender;
- (IBAction)buttonYellow:(id)sender;
- (IBAction)buttonSelect:(id)sender;
- (IBAction)buttonFree:(id)sender;
- (IBAction)buttonAV:(id)sender;

- (IBAction)searchTextChange:(id)sender;

@property (weak) IBOutlet NSSearchField         *searchTextField;
@property (unsafe_unretained) IBOutlet NSWindow *optionsWindow;
@property (weak) IBOutlet NSTextField           *freeboxCodeTextEdit;
@property (weak) IBOutlet NSMenuItem            *optionMenuItem;
@property (weak) IBOutlet NSMenuItem            *quitMenuItem;

- (void)refreshMenu;
- (void)tuneSelectedChannel;
- (void)showOptionsWindow;
- (void)quitApp;
- (bool)isHighlighted:(NSMenuItem*)menuItem;

@end
