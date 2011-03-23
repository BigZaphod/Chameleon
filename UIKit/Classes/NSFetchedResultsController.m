//
//  NSFetchedResultsController.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSFetchedResultsController.h"
#import "NSIndexPath+UITableView.h"

@implementation NSFetchedResultsController

@synthesize delegate = _delegate;
@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedObjects = _fetchedObjects;
@synthesize cacheName = _cacheName, sectionNameKeyPath = _sectionNameKeyPath;

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext: (NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name {
  if ((self = [super init])) {
    _fetchRequest = [fetchRequest retain];
    _managedObjectContext = [context retain];
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

- (NSArray *)sections {
  // stub
  return [NSArray array];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
  return 0;
}




@end
