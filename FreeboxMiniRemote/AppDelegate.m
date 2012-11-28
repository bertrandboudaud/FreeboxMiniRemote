//
//  AppDelegate.m
//  FreeboxMiniRemote
//
//  Created by Bertrand Boudaud on 04/07/12.
//  Copyright (c) 2012 Bertrand Boudaud. All rights reserved.
//

#import "AppDelegate.h"
#import "ChannelMenuItemView.h"
#import "OptionsMenuItemView.h"
#import "QuitMenuItemView.h"

@implementation AppDelegate

@synthesize searchTextField;
@synthesize optionsWindow;
@synthesize freeboxCodeTextEdit;
@synthesize optionMenuItem;
@synthesize quitMenuItem;
@synthesize filteredChannels;
@synthesize updateMenuInvocation;
@synthesize updateTimer;
@synthesize nbMaxFilteredItems;
@synthesize channels;
@synthesize filteredChannelsMenuItems;
@synthesize pendingCommands;
@synthesize currentCommand;
@synthesize showMenuOnActivation;
@synthesize selectedMenuItem;
@synthesize selectedMenuItemIndex;
@synthesize options;

-(void)awakeFromNib{
   
   
   // read options from file
   options = [[NSMutableDictionary alloc] initWithContentsOfFile:@"useroptions" ];
   if (options==nil)
   {
      // default value
      // 89196530
      options = [[NSMutableDictionary alloc] init ];
      [options setValue:@"" forKey:@"freeboxcode"];
      [options setValue:[[NSNumber alloc] initWithInt:100] forKey:@"version"];
   }
   
   // Setup Status Item
   statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
   [statusItem setMenu:statusMenu];
   NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"StatusIcon" ofType:@"png"];
   NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
   [statusItem setImage:icon];
   [statusItem setHighlightMode:YES];
   [statusItem setMenu:nil];
   [statusItem setAction:@selector(showMenu:)];
   showMenuOnActivation = false;
   [statusMenu setDelegate:self];
   
   // Set the first menu item to our custom item
   NSMenuItem *menuItem = [statusMenu itemAtIndex:0];
   menuItem.view = mainMenuItem;
   //[statusMenu removeItem:menuItem];
   
   // Allocate arrays for filtering
   filteredChannels = [[NSMutableArray alloc] init];
   filteredChannelsMenuItems = [[NSMutableArray alloc] init];
   pendingCommands = [[NSMutableArray alloc] init];
   
   // Load channels
   [self loadChannels];
   
   [searchTextField setDelegate:self];
   [freeboxCodeTextEdit setDelegate:self];
   [optionsWindow orderOut:nil];
   
   nbMaxFilteredItems = 10;
   
   selectedMenuItemIndex = 0;
   
   int width = [mainMenuItem bounds].size.width;
   
   // set option menu item to a custom view
   OptionsMenuItemView * optionView = [[OptionsMenuItemView alloc] initWithFrame:CGRectMake(0, 0, width , 20)];
   optionMenuItem.view = optionView;
   optionView.menuItem = optionMenuItem;
   
   // set quit menu item to a custom view
   QuitMenuItemView * quitView = [[QuitMenuItemView alloc] initWithFrame:CGRectMake(0, 0, width , 20)];
   quitMenuItem.view = quitView;
   quitView.menuItem = quitMenuItem;
    
    //
    [optionsWindow setBackgroundColor:[NSColor colorWithCalibratedRed:0.45 green:0.40 blue:0.36 alpha:1.0f]];
   
   // set option window additionnal behaviors
   [freeboxCodeTextEdit setStringValue:[options valueForKey:@"freeboxcode"]];
}


- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
   NSEvent *event = [NSApp currentEvent];
   unichar buf;
   NSString *test = [event characters];
   [test getCharacters:&buf range:NSMakeRange(0,1)];
   switch (buf)
   {
      case NSUpArrowFunctionKey:
         NSLog(@"Arrow up key");
         if (selectedMenuItemIndex>0)
         {
            selectedMenuItemIndex--;
            [self refreshMenu];
         }
         return true;
      case NSDownArrowFunctionKey:
         NSLog(@"Arrow down key");
         if (selectedMenuItemIndex<([filteredChannelsMenuItems count] + 1))
         {
            selectedMenuItemIndex++;
            [self refreshMenu];
         }
         return true;
      case 0xd:
         NSLog(@"Enter key");
         if ([self isHighlighted:optionMenuItem])
         {
            [self showOptionsWindow];
         }
         else if ([self isHighlighted:quitMenuItem])
         {
            [self quitApp];
         }
         else
         {
            [self tuneSelectedChannel];
         }
         return true;
      default:
         return false;
   }
}

- (void)loadChannels
{
   NSString* path = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"json"];
   NSData *jsonChannelTxt = [[NSData alloc] initWithContentsOfFile:path];
   NSLog(@"JSon data : %lu",[jsonChannelTxt length]);
   NSError* error;
   channels = [NSJSONSerialization
               JSONObjectWithData:jsonChannelTxt
               options:NSJSONReadingMutableContainers
               error:&error];
   for (id channel in channels)
   {
      NSLog(@"channel: %@", [channel valueForKey:@"name"]);
   }
   
   // remove double names (this removes TF1 SD ...)
   NSMutableArray *channelNames = [[NSMutableArray alloc] init];
   NSMutableArray *channelsToRemove = [[NSMutableArray alloc] init];
   for (id channel in channels)
   {
      NSString *channelName = [channel valueForKey:@"name"];
      if ([channelNames indexOfObject:channelName]==NSNotFound)
      {
         [channelNames addObject:channelName];
      }
      else
      {
         [channelsToRemove addObject:channel];
      }
   }
   for (id channel in channelsToRemove)
   {
      [channels removeObject:channel];
   }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   updateMenuInvocation = [NSInvocation invocationWithMethodSignature:
                           [self methodSignatureForSelector:@selector(updateMenuInvocation)]];
   [updateMenuInvocation setTarget:self];
   [updateMenuInvocation setSelector:@selector(updateMenu)];
}

- (void)clearFilteredItems
{
   for (NSMenuItem * menuItem in filteredChannelsMenuItems)
   {
      [statusMenu removeItem:menuItem];
   }
   [filteredChannelsMenuItems removeAllObjects];
   [filteredChannels removeAllObjects];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSLog(@"controlTextDidChange");
    if ([notification object] == searchTextField) {
        [self updateMenu];
    }
    else if ([notification object] == freeboxCodeTextEdit) {
        [options setValue:[freeboxCodeTextEdit stringValue] forKey:@"freeboxcode"];
        [options writeToFile:@"useroptions" atomically:YES];
    }
}

- (void)executeCommand:(NSString *)command
{
   //   int code = 89196530;
   NSString *requeteString = [[NSString alloc] initWithFormat:@"http://hd1.freebox.fr/pub/remote_control?code=%@&key=%@",[options valueForKey:@"freeboxcode"],command];
   
   NSLog(@"Launch request %@",requeteString);
   
   NSMutableURLRequest *maRequete = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requeteString]];
   [maRequete setHTTPMethod:@"GET"];
   [maRequete setTimeoutInterval:2.0];
   [NSURLConnection sendAsynchronousRequest:maRequete queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
       if ([data length] >0 && error == nil)
       {
          NSString *test = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
          NSLog(@"%@",test);
          // discard all
          currentCommand = nil;
          [pendingCommands removeAllObjects];
       }
       else if ([data length] == 0 && error == nil)
       {
          NSLog(@"Server sent no data");
          // execute next command
          if ([pendingCommands count]>0)
          {
             currentCommand = [pendingCommands objectAtIndex:0];
             [pendingCommands removeObject:currentCommand];
             [self executeCommand:currentCommand];
          }
          else
          {
             currentCommand = nil;
          }
       }
       else if (error != nil){
          NSLog(@"Error = %@", error);
          // discard all
          currentCommand = nil;
          [pendingCommands removeAllObjects];
       }
    }];
}

- (void)sendFreeboxCommand:(NSString *)command
{
   if (currentCommand == nil)
   {
      currentCommand = command;
      [self executeCommand:currentCommand];
   }
   else
   {
      [pendingCommands addObject:command];
   }
}

- (IBAction)buttonPGPlus:(id)sender {
   NSLog(@"buttonPGPlus");
   [self sendFreeboxCommand:@"prgm_inc"];
}

- (IBAction)buttonPGMinus:(id)sender {
   NSLog(@"buttonPGMinus");
   [self sendFreeboxCommand:@"prgm_dec"];
}

- (IBAction)buttonVolPlus:(id)sender {
   NSLog(@"buttonVolPlus");
   [self sendFreeboxCommand:@"vol_inc"];
}

- (IBAction)buttonVolMinus:(id)sender {
   NSLog(@"buttonVolMinus");
   [self sendFreeboxCommand:@"vol_dec"];
}

- (IBAction)searchTextChange:(id)sender {
   NSLog(@"Search button activated");
}

- (IBAction)buttonOptions:(id)sender {
   NSLog(@"Options button activated");
   NSWindow *window = [self optionsWindow];
   [window makeKeyAndOrderFront:nil];
   [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)buttonMute:(id)sender {
   NSLog(@"buttonMute");
   [self sendFreeboxCommand:@"mute"];
}

- (IBAction)buttonPower:(id)sender {
   NSLog(@"buttonPower");
   [self sendFreeboxCommand:@"power"];
}

- (IBAction)button1:(id)sender {
    NSLog(@"button1");
    [self sendFreeboxCommand:@"1"];
}

- (IBAction)button2:(id)sender {
    NSLog(@"button2");
    [self sendFreeboxCommand:@"2"];
}

- (IBAction)button3:(id)sender {
    NSLog(@"button3");
    [self sendFreeboxCommand:@"3"];
}

- (IBAction)button4:(id)sender {
    NSLog(@"button4");
    [self sendFreeboxCommand:@"4"];
}

- (IBAction)button5:(id)sender {
    NSLog(@"button5");
    [self sendFreeboxCommand:@"5"];
}

- (IBAction)button6:(id)sender {
    NSLog(@"button6");
    [self sendFreeboxCommand:@"6"];
}

- (IBAction)button7:(id)sender {
    NSLog(@"button7");
    [self sendFreeboxCommand:@"7"];
}

- (IBAction)button8:(id)sender {
    NSLog(@"button8");
    [self sendFreeboxCommand:@"8"];
}

- (IBAction)button9:(id)sender {
    NSLog(@"button9");
    [self sendFreeboxCommand:@"9"];
}

- (IBAction)button0:(id)sender {
    NSLog(@"button0");
    [self sendFreeboxCommand:@"0"];
}

- (IBAction)buttonBwd:(id)sender {
    NSLog(@"buttonBwd");
    [self sendFreeboxCommand:@"bwd"];
}

- (IBAction)buttonFwd:(id)sender {
    NSLog(@"buttonFwd");
    [self sendFreeboxCommand:@"fwd"];
}

- (IBAction)buttonRec:(id)sender {
    NSLog(@"buttonRec");
    [self sendFreeboxCommand:@"rec"];
}

- (IBAction)buttonPlay:(id)sender {
    NSLog(@"buttonPlay");
    [self sendFreeboxCommand:@"play"];
}

- (IBAction)buttonUp:(id)sender {
    NSLog(@"buttonUp");
    [self sendFreeboxCommand:@"up"];
}

- (IBAction)buttonDown:(id)sender {
    NSLog(@"buttonDown");
    [self sendFreeboxCommand:@"down"];
}

- (IBAction)buttonLeft:(id)sender {
    NSLog(@"buttonLeft");
    [self sendFreeboxCommand:@"left"];
}

- (IBAction)buttonRight:(id)sender {
    NSLog(@"buttonRight");
    [self sendFreeboxCommand:@"right"];
}

- (IBAction)buttonRed:(id)sender {
    NSLog(@"buttonRed");
    [self sendFreeboxCommand:@"red"];
}

- (IBAction)buttonGreen:(id)sender {
    NSLog(@"buttonGreen");
    [self sendFreeboxCommand:@"green"];
}

- (IBAction)buttonYellow:(id)sender {
    NSLog(@"buttonYellow");
    [self sendFreeboxCommand:@"yellow"];
}

- (IBAction)buttonBlue:(id)sender {
    NSLog(@"buttonBlue");
    [self sendFreeboxCommand:@"blue"];
}

- (IBAction)buttonSelect:(id)sender {
    NSLog(@"buttonSelect");
    [self sendFreeboxCommand:@"ok"];
}

- (IBAction)buttonFree:(id)sender {
    NSLog(@"buttonFree");
    [self sendFreeboxCommand:@"home"];
}

- (IBAction)buttonAV:(id)sender {
    NSLog(@"buttonAV");
    [self sendFreeboxCommand:@"av"];
}

- (void)menuDidClose:(NSMenu *)menu
{
   NSLog(@"menuDidClose (active? %d)",[NSApp isActive]);
   NSMenuItem *menuItem = [statusMenu itemAtIndex:0];
   menuItem.view = nil;
   showMenuOnActivation = false;
}

- (void)menuWillOpen:(NSMenu *)menu
{
   NSLog(@"menuWillOpen (active? %d)",[NSApp isActive]);
   [self clearFilteredItems]; // do not call this into close.
   [[searchTextField window] makeFirstResponder:[searchTextField window]];
   NSMenuItem *menuItem = [statusMenu itemAtIndex:0];
   menuItem.view = mainMenuItem;
   [searchTextField setDelegate:self];
   [searchTextField becomeFirstResponder];
   [optionsWindow orderOut:self];
   [searchTextField setStringValue:@""];
}

- (void)tuneSelectedChannel
{
   if ([filteredChannelsMenuItems count])
   {
      NSMenuItem * selectedItem = [filteredChannelsMenuItems objectAtIndex:selectedMenuItemIndex];
      [self selectChannel:selectedItem];
      [statusMenu cancelTracking];
   }
}

- (void) selectChannel: (id)sender
{
   NSString* channelName = [(NSMenuItem *)sender title];
   NSString * command = nil;
   NSLog(@"selectChannel %@\n",channelName);
   for (id channel in channels)
   {
      NSString *testedChannel =[channel valueForKey:@"name"];
      if ([testedChannel isEqualToString:channelName])
      {
         int commandInt = [[channel valueForKey:@"id"] intValue];
         command = [[NSString alloc] initWithFormat:@"%d", commandInt];
         NSLog(@"channel: %@ command %@", channelName, command);
         break;
      }
   }
   if (command!=nil)
   {
      for (int i=0;i<[command length];i++)
      {
         unichar digit = [command characterAtIndex:i];
         NSString *commandPart = [[NSString alloc] initWithCharacters:&digit length:1];
         [self sendFreeboxCommand:commandPart];
      }
   }
}

- (void) showMenu: (id)sender
{
   NSLog(@"showMenu");
   if (![NSApp isActive])
   {
      showMenuOnActivation = true;
      [NSApp activateIgnoringOtherApps:YES];
   }
   else
   {
      [statusItem popUpStatusItemMenu:statusMenu];
   }
}


- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
   NSLog(@"applicationDidBecomeActive");
   if (showMenuOnActivation)
   {
      [statusItem popUpStatusItemMenu:statusMenu];
   }
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
   NSLog(@"applicationWillResignActive");
}

-(NSMenuItem *)createChannelMenuItem:title action:(SEL)action keyEquivalent:(NSString*)keyEquivalent
{
   int width = [mainMenuItem bounds].size.width;
   NSMenuItem *channelItemTest = [[NSMenuItem alloc] initWithTitle:title action:@selector(selectChannel:) keyEquivalent:@""];
   ChannelMenuItem * channelMenuItemView = [[ChannelMenuItem alloc] initWithFrame:CGRectMake(0, 0, width , 20)];
   channelItemTest.view = channelMenuItemView;
   channelMenuItemView.menuItem = channelItemTest;
   [channelItemTest setEnabled:FALSE];
   return channelItemTest;
}

int counter = 0;
- (void)updateMenu;
{
   NSLog(@"updateMenu");
   
   [filteredChannels removeAllObjects];
   NSString *searchString = [[searchTextField stringValue] lowercaseString];
   for (id channel in channels)
   {
      NSString * channelTest = [channel valueForKey:@"name"];
      if ([[channelTest lowercaseString] rangeOfString:searchString].location != NSNotFound)
      {
         NSLog(@"filtered channel: %@", channelTest);
         [filteredChannels addObject:channelTest];
      }
   }
   
   [self refreshMenu];
   
   // highlight default
   if ([filteredChannelsMenuItems count]>0)
   {
      selectedMenuItemIndex = 0;
   }
}

- (void)refreshMenu
{
   // to update the menu, it is not enough to remove all and recreate
   // we need to update title of existing items, and remove the
   // remaining items.
   int current = 0;
   for (NSString* channel in filteredChannels)
   {
      //NSString * title = [[NSString alloc] initWithFormat:@"%@ %lu",channel,counter]; counter++;
      NSString * title = [[NSString alloc] initWithFormat:@"%@",channel];
      NSMenuItem *menuItem = nil;
      if (current < ([filteredChannelsMenuItems count]))
      {
         // just change the title
         menuItem = [filteredChannelsMenuItems objectAtIndex:current];
         [menuItem setTitle:title];
      }
      else
      {
         // create a new item
         menuItem = [self createChannelMenuItem:title action:@selector(selectChannel:) keyEquivalent:@""];
         [statusMenu insertItem:menuItem atIndex:(current+1)];
         [menuItem setTarget:self];
         [filteredChannelsMenuItems addObject:menuItem];
      }
      current++;
      if (current == nbMaxFilteredItems)
      {
         break;
      }
   }
   // remove remaining items
   if ((current < nbMaxFilteredItems) &&
       ([filteredChannelsMenuItems count] > current ))
   {
      unsigned long nbToRemove = [filteredChannelsMenuItems count]-current;
      for (int i=0; i<nbToRemove; i++)
      {
         NSMenuItem * menuItem = [filteredChannelsMenuItems objectAtIndex:current];
         [statusMenu removeItem:menuItem];
         [filteredChannelsMenuItems removeObject:menuItem];
         //current++;
      }
   }
   
   // ------------
   
   for (int i=0;i<[filteredChannelsMenuItems count];i++)
   {
      NSMenuItem * menuItem = [filteredChannelsMenuItems objectAtIndex:i];
      NSString *title = [menuItem title];
      [menuItem setTitle:@""];
      [menuItem setTitle:title];
   }
   
   // force a refresh
   NSString *oldValue = @"";
   oldValue = [optionMenuItem title];
   [optionMenuItem setTitle:@""];
   [optionMenuItem setTitle:oldValue];
   oldValue = [quitMenuItem title];
   [quitMenuItem setTitle:@""];
   [quitMenuItem setTitle:oldValue];
   
}

- (NSMenuItem*)selectedMenuItem
{
   // do something else
   return [filteredChannelsMenuItems objectAtIndex:selectedMenuItemIndex];
}

-(void)setSelectedMenuItem:(NSMenuItem *)menuItem
{
   if (menuItem==optionMenuItem)
   {
      selectedMenuItemIndex = [filteredChannelsMenuItems count];
   }
   else if (menuItem==quitMenuItem)
   {
      selectedMenuItemIndex = [filteredChannelsMenuItems count] +1;
   }
   else
   {
      selectedMenuItemIndex = [filteredChannelsMenuItems indexOfObject:menuItem];
   }
}

- (bool)isHighlighted:(NSMenuItem*)menuItem
{
   if (menuItem==optionMenuItem)
   {
      return (selectedMenuItemIndex == [filteredChannelsMenuItems count]);
   }
   else if (menuItem==quitMenuItem)
   {
      return (selectedMenuItemIndex == [filteredChannelsMenuItems count] +1 );
   }
   else
   {
      return (selectedMenuItemIndex == [filteredChannelsMenuItems indexOfObject:menuItem]);
   }
}

- (void)showOptionsWindow
{
   [optionsWindow makeKeyAndOrderFront:self];
   [statusMenu cancelTracking];
}

- (void)quitApp
{
   NSLog(@"quitApp");
   [NSApp terminate:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
   NSLog(@"windowWillClose");
   [options setValue:[freeboxCodeTextEdit stringValue] forKey:@"freeboxcode"];
   [options writeToFile:@"useroptions" atomically:YES];
}

@end
