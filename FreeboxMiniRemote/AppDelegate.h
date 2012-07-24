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

@property NSDictionary        *channels;
@property NSMutableArray      *filteredChannels;
@property NSMutableArray      *filteredChannelsMenuItems;
@property NSMutableArray      *pendingCommands;
@property NSString            *currentCommand;
@property bool                showMenuOnActivation;
@property NSInvocation        *updateMenuInvocation;
@property NSTimer             *updateTimer;
@property int                 nbMaxFilteredItems;
@property NSMenuItem          *selectedMenuItem;
@property int                 selectedMenuItemIndex;
@property NSMutableDictionary *options;

- (IBAction)buttonPGMinus:(id)sender;
- (IBAction)buttonPGPlus:(id)sender;
- (IBAction)buttonVolPlus:(id)sender;
- (IBAction)buttonVolMinus:(id)sender;
- (IBAction)buttonOptions:(id)sender;
- (IBAction)buttonMute:(id)sender;
- (IBAction)buttonPower:(id)sender;

- (IBAction)searchTextChange:(id)sender;

@property (weak) IBOutlet NSSearchField         *searchTextField;
@property (unsafe_unretained) IBOutlet NSWindow *optionsWindow;
@property (weak) IBOutlet NSTextField           *freeboxCodeTextEdit;
@property (weak) IBOutlet NSMenuItem            *optionMenuItem;

- (void)refreshMenu;
- (void)tuneSelectedChannel;
- (void)showOptionsWindow;
- (bool)isHighlighted:(NSMenuItem*)menuItem;

@end
