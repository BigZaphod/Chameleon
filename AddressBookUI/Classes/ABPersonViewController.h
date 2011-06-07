//
//  ABPersonViewController.h
//  AddressBookUI
//
//  Copyright (c) 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIViewController.h>
#import <AddressBook/ABAddressBookC.h>
#import "AddressBookUI.h"

@protocol ABPersonViewControllerDelegate;

@interface ABPersonViewController : UIViewController
{
    id<ABPersonViewControllerDelegate> personViewDelegate;
	ABAddressBookRef addressBook;
	ABRecordRef displayedPerson;
	NSArray *displayedProperties;
	BOOL allowsEditing;
	BOOL shouldShowLinkedPeople;
}

@property(nonatomic,assign) id<ABPersonViewControllerDelegate> personViewDelegate;
@property(nonatomic,readwrite) ABAddressBookRef addressBook;
@property(nonatomic,readwrite) ABRecordRef displayedPerson;
@property(nonatomic,copy) NSArray *displayedProperties;
@property(nonatomic) BOOL allowsEditing;
@property(nonatomic) BOOL shouldShowLinkedPeople;

- (void)setHighlightedItemForProperty:(ABPropertyID)property withIdentifier:(ABMultiValueIdentifier)identifier;

@end


@protocol ABPersonViewControllerDelegate <NSObject>

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end
