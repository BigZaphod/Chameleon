//
//  NSFetchedResultsController.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSFetchedResultsController.h"

//#ifdef NSCoreDataVersionNumber10_5

#import "NSIndexPath+UITableView.h"


@interface NSArray (FilteredByBlock)
- (NSArray *)filterByBlock:(BOOL(^)(id elt))filterBlock;
@end

@implementation NSArray (FilteredByBlock)

- (NSArray *)filterByBlock:(BOOL(^)(id elt))filterBlock {
    // Create a new array
    id filteredArray = [NSMutableArray array];
    // Collect elements matching the block condition
    for (id elt in self) {
        if (filterBlock(elt)) [filteredArray addObject:elt];
    }
    
    return filteredArray;
}

@end

@interface NSFetchedResultsSection ()
@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *indexTitle;
@property (nonatomic, readwrite, retain) NSArray *objects;
@end

@implementation NSFetchedResultsSection
@synthesize name, indexTitle, objects;

- (NSUInteger)numberOfObjects {
    return [self.objects count];
}

@end

@interface NSFetchedResultsController ()
@property (nonatomic, retain) NSMutableArray *sortedArray;
@property (nonatomic, readwrite, retain) NSString *sectionNameKeyPath;
@property (nonatomic, readwrite, retain) NSArray *sections;
@end

@implementation NSFetchedResultsController

@synthesize delegate = _delegate;
@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedObjects = _fetchedObjects;
@synthesize cacheName = _cacheName, sectionNameKeyPath = _sectionNameKeyPath;
@synthesize sortedArray = _sortedArray;

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext: (NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name {
  if ((self = [super init])) {
      _fetchRequest = [fetchRequest retain];
      _managedObjectContext = [context retain];
      _sectionNameKeyPath = [sectionNameKeyPath retain];
      
      if (_sectionNameKeyPath) {
          NSMutableArray *sorting = [[_fetchRequest sortDescriptors] mutableCopy];
          if (!sorting) sorting = [NSMutableArray array];
          NSSortDescriptor *groupSD = [NSSortDescriptor sortDescriptorWithKey:_sectionNameKeyPath ascending:YES];
          [sorting insertObject:groupSD atIndex:0];
          [_fetchRequest setSortDescriptors:sorting];
          [sorting release];
      }
  }
  return self;
}

- (void)dealloc {
  _delegate = nil;
  [_fetchRequest release];
  [_managedObjectContext release];
  [_fetchedObjects release];
  [super dealloc];
}

- (BOOL)performFetch:(NSError **)error {
  [_fetchedObjects release];
  _fetchedObjects = [[_managedObjectContext executeFetchRequest:_fetchRequest error:error] retain];
        
    if (!self.sectionNameKeyPath) {
        
        NSFetchedResultsSection *oneSection = [[[NSFetchedResultsSection alloc] init] autorelease];
        oneSection.objects = _fetchedObjects;
        self.sections = [NSArray arrayWithObject:oneSection];
        
        return YES;
    }
    
    NSMutableArray *sectionArray = [NSMutableArray array];
    
    NSMutableArray *sortedByGrouping = [_fetchedObjects mutableCopy];
    self.sortedArray = [NSMutableArray arrayWithCapacity:[sortedByGrouping count]];
    
    
    
    while ([sortedByGrouping count]) 
    {
        NSManagedObject *groupLead = [sortedByGrouping objectAtIndex:0];
        id groupLeadKeyValue = [groupLead valueForKeyPath:self.sectionNameKeyPath];
        
        
        NSArray *group = [sortedByGrouping filterByBlock:^BOOL(id elt) {
            return [[elt valueForKeyPath:_sectionNameKeyPath] isEqual:groupLeadKeyValue];
        }];
        
        NSFetchedResultsSection *oneSection = [[[NSFetchedResultsSection alloc] init] autorelease];
        oneSection.objects = group;
        oneSection.name = [groupLeadKeyValue description];
        
        [sectionArray addObject:oneSection];
        
        //NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"%@ == %@", self.sectionNameKeyPath, groupLeadKeyValue];
        //NSArray *group = [sortedByGrouping filteredArrayUsingPredicate:groupPredicate];
        
        //[self.sortedArray addObjectsFromArray:group];
        [sortedByGrouping removeObjectsInArray:group];
    }
    
    self.sections = sectionArray;

  return YES;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
  return [_fetchedObjects objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
  NSUInteger objectIndex = [_fetchedObjects indexOfObject:object];
  return [NSIndexPath indexPathForRow:objectIndex inSection:0];
}

// stubs

+ (void)deleteCacheWithName:(NSString *)name {
  // stub
}


- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName {
  return @"UNIMPLEMENTED";
}

- (NSArray *)sectionIndexTitles {
  // stub
  return [NSArray array];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
  return 0;
}

@end

//#endif
