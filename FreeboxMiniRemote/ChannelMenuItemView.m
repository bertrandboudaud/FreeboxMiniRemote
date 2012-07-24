//
//  ChannelMenuItem.m
//  FreeboxMiniRemote
//
//  Created by Bertrand Boudaud on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelMenuItemView.h"
#import "AppDelegate.h"

@implementation ChannelMenuItem

@synthesize menuItem;

- (id)initWithFrame:(NSRect)frameRect 
{
   if ((self = [super initWithFrame:frameRect]) == nil) {
      return self;
   }
   
   [self addTrackingRect:[self bounds] 
                   owner:self 
                userData:nil
            assumeInside:NO];
   
   return self;
}


-(void)mouseEntered:(NSEvent*)theEvent 
{ 
   AppDelegate *myAppDelegate = [NSApp delegate] ;
   [myAppDelegate setSelectedMenuItem:menuItem];
   [myAppDelegate refreshMenu];
}

- (void)mouseDown:(NSEvent *)theEvent
{
   NSLog(@"mouseDown");
   AppDelegate *myAppDelegate = [NSApp delegate] ;
   [myAppDelegate tuneSelectedChannel];
}


- (void) drawRect:(NSRect)dirtyRect
{
   
   AppDelegate *myAppDelegate = [NSApp delegate] ;
   bool highlighted = [myAppDelegate isHighlighted:menuItem];

   // draw rectangle
   [[NSBezierPath bezierPathWithRect:[self bounds]] setClip];
   if (highlighted)
   {
      [[NSColor selectedMenuItemColor] set];
   }
   else 
   {
      [[NSColor controlBackgroundColor] set];
   }
   NSRectFill( [self bounds] );
   
   // draw text
   NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle
                                          alloc] init];
   NSMutableDictionary *attributes = [NSMutableDictionary 
                                      dictionaryWithObject:paraStyle 
                                      forKey:NSParagraphStyleAttributeName];
   if (highlighted)
   {
      [attributes setValue:[NSColor selectedMenuItemTextColor] 
                    forKey:NSForegroundColorAttributeName];
   }
   else 
   {
      [attributes setValue:[NSColor controlTextColor] 
                    forKey:NSForegroundColorAttributeName];
   }
   [attributes setValue:[NSFont menuFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];
   NSString *text = menuItem.title;
   NSRect textBounds = [self bounds];
   textBounds.origin.x = 4; // margin
   [text drawInRect:textBounds withAttributes:attributes];
}

@end
