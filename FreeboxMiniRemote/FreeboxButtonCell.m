//
//  FreeboxButtonCell.m
//  FreeboxMiniRemote
//
//  Created by Bertrand Boudaud on 26/11/12.
//
//

#import "FreeboxButtonCell.h"

@implementation FreeboxButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{

    const int border = 4;
    NSPoint topRight = NSMakePoint(frame.origin.x+frame.size.width,frame.origin.y);
    NSPoint bottomRight = NSMakePoint(frame.origin.x+frame.size.width,frame.origin.y+frame.size.height);
    NSPoint innerTopRight = NSMakePoint(topRight.x-border,topRight.y+border);
    NSPoint innerBottomRight = NSMakePoint(bottomRight.x-border,bottomRight.y-border);
    NSPoint topLeft = NSMakePoint(frame.origin.x,frame.origin.y);
    NSPoint bottomLeft = NSMakePoint(frame.origin.x,frame.origin.y+frame.size.height);
    NSPoint innerTopLeft = NSMakePoint(topLeft.x+border,topLeft.y+border);
    NSPoint innerBottomLeft = NSMakePoint(bottomLeft.x+border,bottomLeft.y-border);

    NSColor *freeboxColorPlain = [NSColor colorWithCalibratedRed:0.45 green:0.40 blue:0.36 alpha:1.0f];
    NSColor *freeboxColorDark = [NSColor colorWithCalibratedRed:0.36 green:0.33 blue:0.29 alpha:1.0f];
    NSColor *freeboxColorLight = [NSColor colorWithCalibratedRed:0.53 green:0.48 blue:0.42 alpha:1.0f];

    NSColor *redColorPlain = [NSColor colorWithCalibratedRed:0.59 green:0.0 blue:0.02 alpha:1.0f];
    NSColor *redColorDark  = [NSColor colorWithCalibratedRed:0.30 green:0.0 blue:0.0 alpha:1.0f];

    NSColor *greenColorPlain = [NSColor colorWithCalibratedRed:0.20 green:0.82 blue:0 alpha:1.0f];
    NSColor *greenColorDark  = [NSColor colorWithCalibratedRed:0.10 green:0.43 blue:0 alpha:1.0f];
    
    NSColor *blueColorPlain = [NSColor colorWithCalibratedRed:0.12 green:0.67 blue:0.93 alpha:1.0f];
    NSColor *blueColorDark  = [NSColor colorWithCalibratedRed:0.06 green:0.32 blue:0.47 alpha:1.0f];
    
    NSColor *yellowColorPlain = [NSColor colorWithCalibratedRed:0.63 green:0.70 blue:0 alpha:1.0f];
    NSColor *yellowColorDark  = [NSColor colorWithCalibratedRed:0.30 green:0.35 blue:0 alpha:1.0f];
    
    NSColor *rightShadow;
    NSColor *leftShadow;
    NSColor *buttonColor;
    
    switch ([self tag]) {
        case 1:
        {
            if([self isHighlighted])
            {
                rightShadow = freeboxColorLight;
                leftShadow = freeboxColorDark;
                buttonColor = redColorDark;
            }
            else
            {
                rightShadow = freeboxColorDark;
                leftShadow = freeboxColorLight;
                buttonColor = redColorPlain;
            }
        }
        break;
            
        case 4:
        {
            if([self isHighlighted])
            {
                rightShadow = freeboxColorLight;
                leftShadow = freeboxColorDark;
                buttonColor = greenColorDark;
            }
            else
            {
                rightShadow = freeboxColorDark;
                leftShadow = freeboxColorLight;
                buttonColor = greenColorPlain;
            }
        }
        break;
 
        case 3:
        {
            if([self isHighlighted])
            {
                rightShadow = freeboxColorLight;
                leftShadow = freeboxColorDark;
                buttonColor = yellowColorDark;
            }
            else
            {
                rightShadow = freeboxColorDark;
                leftShadow = freeboxColorLight;
                buttonColor = yellowColorPlain;
            }
        }
        break;

        case 2:
        {
            if([self isHighlighted])
            {
                rightShadow = freeboxColorLight;
                leftShadow = freeboxColorDark;
                buttonColor = blueColorDark;
            }
            else
            {
                rightShadow = freeboxColorDark;
                leftShadow = freeboxColorLight;
                buttonColor = blueColorPlain;
            }
        }
        break;

        default:
        {
            if([self isHighlighted])
            {
                rightShadow = freeboxColorLight;
                leftShadow = freeboxColorDark;
                buttonColor = freeboxColorDark;
            }
            else
            {
                rightShadow = freeboxColorDark;
                leftShadow = freeboxColorLight;
                buttonColor = freeboxColorPlain;
            }
        }
        break;
    }
    
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

    [ctx saveGraphicsState];
    [buttonColor set ] ;
    NSBezierPath* myPath = [NSBezierPath new] ;
    [myPath appendBezierPathWithRect: frame] ;
    [myPath fill] ;
    [ctx restoreGraphicsState];
    

    NSBezierPath* darkShadowPath;

    [ctx saveGraphicsState];
    [rightShadow set ] ;
    darkShadowPath = [NSBezierPath bezierPath];
    [darkShadowPath moveToPoint:topRight];
    [darkShadowPath lineToPoint:bottomRight];
    [darkShadowPath lineToPoint:innerBottomRight];
    [darkShadowPath lineToPoint:innerTopRight];
    [darkShadowPath closePath];
    [darkShadowPath addClip];
    [myPath fill] ;
    [ctx restoreGraphicsState];

    [ctx saveGraphicsState];
    [rightShadow set ] ;
    darkShadowPath = [NSBezierPath bezierPath];
    [darkShadowPath moveToPoint:innerBottomRight];
    [darkShadowPath lineToPoint:bottomRight];
    [darkShadowPath lineToPoint:bottomLeft];
    [darkShadowPath lineToPoint:innerBottomLeft];
    [darkShadowPath closePath];
    [darkShadowPath addClip];
    [myPath fill] ;
    [ctx restoreGraphicsState];
    
    [ctx saveGraphicsState];
    [leftShadow set ] ;
    darkShadowPath = [NSBezierPath bezierPath];
    [darkShadowPath moveToPoint:topLeft];
    [darkShadowPath lineToPoint:innerTopLeft];
    [darkShadowPath lineToPoint:innerBottomLeft];
    [darkShadowPath lineToPoint:bottomLeft];
    [darkShadowPath closePath];
    [darkShadowPath addClip];
    [myPath fill] ;
    [ctx restoreGraphicsState];

    [ctx saveGraphicsState];
    [leftShadow set ] ;
    darkShadowPath = [NSBezierPath bezierPath];
    [darkShadowPath moveToPoint:topLeft];
    [darkShadowPath lineToPoint:topRight];
    [darkShadowPath lineToPoint:innerTopRight];
    [darkShadowPath lineToPoint:innerTopLeft];
    [darkShadowPath closePath];
    [darkShadowPath addClip];
    [myPath fill] ;
    [ctx restoreGraphicsState];

}

- (void)drawImage:(NSImage*)image
        withFrame:(NSRect)frame
           inView:(NSView*)controlView
{
}




- (NSRect)drawTitle:(NSAttributedString*)title
          withFrame:(NSRect)frame
             inView:(NSView*)controlView
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [context graphicsPort];
    CGContextSaveGState(contextRef);
    [context setShouldAntialias:YES];
    
    NSDictionary *attributes = nil;
    
    NSColor *titleColor = [NSColor colorWithCalibratedRed: 1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setAlignment:NSCenterTextAlignment];
    attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                  style, NSParagraphStyleAttributeName,
                  titleColor,
                  NSForegroundColorAttributeName,
                  [NSFont systemFontOfSize:11], NSFontAttributeName, nil];
    
    NSMutableAttributedString *attrString = [title mutableCopy];
    [attrString beginEditing];
    [attrString addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(0, [[self title] length])];
    [attrString endEditing];
    
    [super drawTitle:attrString withFrame:frame inView:controlView];
    
    CGContextRestoreGState(contextRef);
    return frame;
}

@end
