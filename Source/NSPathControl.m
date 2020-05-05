/* Implementation of class NSPathControl
   Copyright (C) 2020 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: Wed Apr 22 18:19:40 EDT 2020

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#import <Foundation/NSNotification.h>

#import "AppKit/NSPathControl.h"
#import "AppKit/NSPathCell.h"
#import "AppKit/NSGraphics.h"
#import "AppKit/NSDragging.h"
#import "AppKit/NSPasteboard.h"
#import "AppKit/NSMenu.h"
#import "AppKit/NSOpenPanel.h"
#import "AppKit/NSPathComponentCell.h"

static NSNotificationCenter *nc = nil;

@interface NSPathCell (PathControlPrivate)
- (void) _setClickedPathComponentCell: (NSPathComponentCell *)c;
@end

@implementation NSPathControl

+ (void) initialize
{
  if (self == [NSPathControl class])
    {
      [self setVersion: 1.0];
      [self setCellClass: [NSPathCell class]];
      nc = [NSNotificationCenter defaultCenter];
    }
}

- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      [self setPathStyle: NSPathStyleStandard];
      [self setPathComponentCells: nil];
      [self setURL: nil];
      [self setDelegate: nil];
      [self setAllowedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_backgroundColor);
  [super dealloc];
}

- (void) setPathStyle: (NSPathStyle)style
{
  [_cell setPathStyle: style];
  [self setNeedsDisplay];
}

- (NSPathStyle) pathStyle
{
  return [_cell pathStyle];
}

- (NSPathComponentCell *) clickedPathComponentCell
{
  return [_cell clickedPathComponentCell];
}

- (NSArray *) pathComponentCells
{
  return [_cell pathComponentCells];
}

- (void) setPathComponentCells: (NSArray *)cells
{
  [_cell setPathComponentCells: cells];
  [self setNeedsDisplay];
}

- (SEL) doubleAction;
{
  return [_cell doubleAction];
}

- (void) setDoubleAction: (SEL)doubleAction
{
  [_cell setDoubleAction: doubleAction];
}

- (NSURL *) URL
{
  return [_cell URL];
}

- (void) setURL: (NSURL *)url
{
  [_cell setURL: url];
  [self setNeedsDisplay];
}

- (id<NSPathControlDelegate>) delegate
{
  return _delegate;
}

- (void) setDelegate: (id<NSPathControlDelegate>) delegate
{
  _delegate = delegate;
}

- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL)flag
{
  if (flag)
    {
      return _localMask;
    }

  return _remoteMask;
}

- (void) setDraggingSourceOperationMask: (NSDragOperation)mask 
                               forLocal: (BOOL)local
{
  if (local)
    {
      _localMask = mask;
    }
  else
    {
      _remoteMask = mask;
    }
}

- (NSMenu *) menu
{
  return [super menu];
}

- (void) setMenu: (NSMenu *)menu
{
  [super setMenu: menu];
}

- (NSArray *) allowedTypes;
{
  return [_cell allowedTypes];
}

- (void) setAllowedTypes: (NSArray *)allowedTypes
{
  [_cell setAllowedTypes: allowedTypes];
  [self registerForDraggedTypes: allowedTypes];
}

- (NSPathControlItem *) clickedPathItem
{
  return nil;
}

- (NSArray *) pathItems
{
  return _pathItems;
}

- (void) setPathItems: (NSArray *)items
{
  ASSIGNCOPY(_pathItems, items);
  [self setNeedsDisplay];
}

- (NSAttributedString *) placeholderAttributedString
{
  return [_cell placeholderAttributedString];
}

- (void) setPlaceholderAttributedString: (NSAttributedString *)string
{
  [_cell setPlaceholderAttributedString: string];
  [self setNeedsDisplay];
}

- (NSString *) placeholderString
{
  return [_cell placeholderString];
}

- (void) setPlaceholderString: (NSString *)string
{
  [_cell setPlaceholderString: string];
  [self setNeedsDisplay];
}

- (NSColor *) backgroundColor
{
  return _backgroundColor;
}

- (void) setBackgroundColor: (NSColor *)color
{
  ASSIGN(_backgroundColor, color);
  [self setNeedsDisplay];
}

- (void) setAction: (SEL)action
{
  _action = action;
}

- (SEL) action
{
  return _action;
}

- (void) setTarget: (id)target
{
  _target = target;
}

- (id) target
{
  return _target;
}

- (void) _doMenuAction: (id)sender
{
  NSArray *cells = [self pathComponentCells];
  NSUInteger c = [cells count];
  NSUInteger i = [[sender menu] indexOfItem: sender];
  NSUInteger ci = (c - i) + 1;
  NSPathComponentCell *cc = [cells objectAtIndex: ci];

  [_cell _setClickedPathComponentCell: cc];
  if (_action)
    {
      [self sendAction: _action
                    to: _target];
    }
  
  [self setURL: [cc URL]];
  [[sender menu] close];
}

- (void) _doChooseMenuAction: (id)sender
{
  NSOpenPanel *op = [NSOpenPanel openPanel];
  int result = 0;
  
  [op setAllowsMultipleSelection: NO];
  [op setCanChooseFiles: YES];
  [op setCanChooseDirectories: YES];
  
  if ([(id)_delegate respondsToSelector: @selector(pathCell:willPopUpMenu:)])
    {
      [_delegate pathControl: self
        willDisplayOpenPanel: op];
    }

  if ([(id)[_cell delegate] respondsToSelector: @selector(pathCell:willPopUpMenu:)])
    {
      [[_cell delegate] pathCell: _cell
            willDisplayOpenPanel: op];
    }
  
  result = [op runModalForDirectory: nil
                               file: nil
                              types: nil];
  if (result == NSOKButton)
    {
      NSArray *urls = [op URLs];
      NSURL *url = [urls objectAtIndex: 0];
      [self setURL: url];
    }

  [[sender menu] close];
}

- (void) mouseDown: (NSEvent *)event
{
  if (![self isEnabled])
    {
      [super mouseDown: event];
      return;
    }

  if ([self pathStyle] == NSPathStylePopUp)
    {
      NSPathCell *acell = (NSPathCell *)[self cell];
      NSArray *array = [acell pathComponentCells];
      NSMenu *menu = [[NSMenu alloc] initWithTitle: @"Select File"];
      NSPathComponentCell *c = nil;
      NSEnumerator *en = [array objectEnumerator];
      
      while((c = [en nextObject]) != nil)
        {
          NSURL *u = [c URL];
          NSString *s = [[u path] lastPathComponent];
          NSMenuItem *i = [[NSMenuItem alloc] init];

          [i setTitle: s];
          [i setTarget: self];
          [i setAction: @selector(_doMenuAction:)];
          
          [menu insertItem: i
                   atIndex: 0]; 
        }

      // Add separator
      [menu insertItem: [NSMenuItem separatorItem]
               atIndex: 0];

      // Add choose menu option
      NSMenuItem *i = [[NSMenuItem alloc] init];
      [i setTitle: @"Choose..."];
      [i setTarget: self];
      [i setAction: @selector(_doChooseMenuAction:)];
      [menu insertItem: i
               atIndex: 0];
      
      if (_delegate)
        {
          if ([(id)_delegate respondsToSelector: @selector(pathControl:willPopUpMenu:)])
            {
              [_delegate pathControl: self
                       willPopUpMenu: menu];
            }
        }
      
      if ([_cell delegate])
        {
          if ([(id)[_cell delegate] respondsToSelector: @selector(pathCell:willPopUpMenu:)])
            {
              [[_cell delegate] pathCell: _cell
                           willPopUpMenu: menu];
            }
        }

      
      [menu popUpMenuPositionItem: [menu itemAtIndex: 0]
                       atLocation: NSMakePoint(0.0, 0.0)
                           inView: self];
    }
  else
    {
      if (_action)
        {
          [self sendAction: _action
                        to: _target];
        }
    }
}

- (NSDragOperation) draggingEntered: (id<NSDraggingInfo>)sender
{
  // if (_delegate != nil)
    {
      NSDragOperation d = [_delegate pathControl: self
                                    validateDrop: sender];
      if (d == NSDragOperationCopy)
        {
          NSPasteboard *pb = [sender draggingPasteboard];
          if ([[pb types] containsObject: NSFilenamesPboardType])
            {
              NSArray *files = [pb propertyListForType: NSFilenamesPboardType];
              if ([files count] > 0)
                {
                  NSString *file = [files objectAtIndex: 0];
                  NSURL *u = [NSURL URLWithString: file];
                  BOOL accept = [_delegate pathControl: self
                                            acceptDrop: sender];
                  if (accept)
                    {
                      [self setURL: u];
                    }
                }
            }
        }
    }

  return NSDragOperationNone;
}

- (instancetype) initWithCoder: (NSKeyedUnarchiver *)coder
{
  self = [super initWithCoder: coder];
  if (self != nil)
    {
      if ([coder allowsKeyedCoding])
        {
          // Defaults for some values which aren't encoded unless they are non-default.
          [self setBackgroundColor: [NSColor windowBackgroundColor]];
          [self setAllowedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];

          if ([coder containsValueForKey: @"NSBackgroundColor"])
            {
              [self setBackgroundColor: [coder decodeObjectForKey: @"NSBackgroundColor"]];
            }

          if ([coder containsValueForKey: @"NSDragTypes"])
            {
              [self setAllowedTypes: [coder decodeObjectForKey: @"NSDragTypes"]];
            }

          if ([coder containsValueForKey: @"NSControlAction"])
            {
              NSString *s = [coder decodeObjectForKey: @"NSControlAction"];
              [self setAction: NSSelectorFromString(s)];
            }
          if ([coder containsValueForKey: @"NSControlTarget"])
            {
              id t = [coder decodeObjectForKey: @"NSControlTarget"];
              [self setTarget: t];
            }
        }
      else
        {
        }
    }
  return self;
}
@end

@implementation NSPathCell (PathControlPrivate)

- (void) _setClickedPathComponentCell: (NSPathComponentCell *)c
{
  _clickedPathComponentCell = c;
}

@end
