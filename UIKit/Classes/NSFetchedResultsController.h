//
//  NSFetchedResultsController.h
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol NSFetchedResultsControllerDelegate;

@class NSFetchRequest;
@class NSManagedObjectContext;


@interface NSFetchedResultsController : NSObject {
  id <NSFetchedResultsControllerDelegate> _delegate;
  NSFetchRequest *_fetchRequest;
  NSManagedObjectContext *_managedObjectContext;
  NSArray *_fetchedObjects; // we don't yet support sections!

  // stubs
  NSString *_sectionNameKeyPath;
  NSString *_sectionNameKey;
  NSString *_cacheName;
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext: (NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name;

- (BOOL)performFetch:(NSError **)error;

@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSString *cacheName;
@property(nonatomic, assign) id <NSFetchedResultsControllerDelegate> delegate;
+ (void)deleteCacheWithName:(NSString *)name;

// accessing objects
@property  (nonatomic, readonly) NSArray *fetchedObjects;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName;
@property (nonatomic, readonly) NSArray *sectionIndexTitles;
@property (nonatomic, readonly) NSArray *sections;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex;

@end


@protocol NSFetchedResultsSectionInfo

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSArray *objects;

@end

@protocol NSFetchedResultsControllerDelegate

enum {
  NSFetchedResultsChangeInsert = 1,
  NSFetchedResultsChangeDelete = 2,
  NSFetchedResultsChangeMove = 3,
  NSFetchedResultsChangeUpdate = 4

};
typedef NSUInteger NSFetchedResultsChangeType;

@optional

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName;

@end