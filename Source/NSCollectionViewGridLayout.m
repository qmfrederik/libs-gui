/* Implementation of class NSCollectionViewGridLayout
   Copyright (C) 2021 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 30-05-2021

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

#import "AppKit/NSCollectionViewGridLayout.h"

@implementation NSCollectionViewGridLayout

- (id) initWithCoder: (NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {
      if ([coder allowsKeyedCoding])
        {
        }
      else
        {
        }
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
}

- (void) setMaximumNumberOfRows: (NSUInteger)maxRows
{
  _maximumNumberOfRows = maxRows;
}

- (NSUInteger) maximumNumberOfRows;
{
  return _maximumNumberOfRows;
}

- (void) setMaximumNumberOfColumns: (NSUInteger)maxCols
{
  _maximumNumberOfColumns = maxCols;
}

- (NSUInteger) maximumNumberOfColumns
{
  return _maximumNumberOfColumns;
}

- (void) setMinimumItemSize: (NSSize)minSize
{
  _minimumItemSize = minSize;
}

- (NSSize) minimumItemSize
{
  return _minimumItemSize;
}

- (void) setMaximumItemSize: (NSSize)maxSize
{
  _maximumItemSize = maxSize;
}

- (NSSize) maximumItemSize
{
  return _maximumItemSize;
}


- (void) setMargins: (NSEdgeInsets)insets
{
  _margins = insets;
}

- (NSEdgeInsets) margins
{
  return _margins;
}

- (void) setMinimumInteritemSpacing: (CGFloat)spacing
{
  _minimumInteritemSpacing = spacing;
}
  
- (CGFloat) minimumInteritemSpacing
{
  return _minimumInteritemSpacing;
}

// Methods to override for specific layouts...
- (void) prepareLayout
{
  [super prepareLayout];
}

- (NSArray *) layoutAttributesForElementsInRect: (NSRect)rect
{
  return nil;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewLayoutAttributes *attrs = [[NSCollectionViewLayoutAttributes alloc] init];
  AUTORELEASE(attrs);
  return attrs;
}

- (NSCollectionViewLayoutAttributes *)
  layoutAttributesForSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind)elementKind
  atIndexPath: (NSIndexPath *)indexPath
{
  return nil;
}

- (NSCollectionViewLayoutAttributes *)
  layoutAttributesForDecorationViewOfKind: (NSCollectionViewDecorationElementKind)elementKind
                              atIndexPath: (NSIndexPath *)indexPath
{
  return nil;
}

- (NSCollectionViewLayoutAttributes *)layoutAttributesForDropTargetAtPoint: (NSPoint)pointInCollectionView
{
  return nil;
}

- (NSCollectionViewLayoutAttributes *)layoutAttributesForInterItemGapBeforeIndexPath: (NSIndexPath *)indexPath
{
  return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange: (NSRect)newBounds
{
  return NO;
}

- (NSCollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange: (NSRect)newBounds
{
  return nil;
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes: (NSCollectionViewLayoutAttributes *)preferredAttributes
                                    withOriginalAttributes: (NSCollectionViewLayoutAttributes *)originalAttributes
{
  return NO;
}

- (NSCollectionViewLayoutInvalidationContext *)
  invalidationContextForPreferredLayoutAttributes: (NSCollectionViewLayoutAttributes *)preferredAttributes
                           withOriginalAttributes: (NSCollectionViewLayoutAttributes *)originalAttributes
{
  return nil;
}

- (NSPoint) targetContentOffsetForProposedContentOffset: (NSPoint)proposedContentOffset
                                  withScrollingVelocity: (NSPoint)velocity
{
  return NSZeroPoint;
}

- (NSPoint) targetContentOffsetForProposedContentOffset: (NSPoint)proposedContentOffset
{
  return NSZeroPoint;  
}

- (NSSize) collectionViewContentSize
{
  return [_collectionView frame].size;
}
// end subclassing hooks...

@end

