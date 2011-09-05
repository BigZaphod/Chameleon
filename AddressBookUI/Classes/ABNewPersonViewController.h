//
//  ABNewPersonViewController.h
//  AddressBookUI
//
//  Copyright (c) 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/ABAddressBookC.h>
#import "AddressBookUI.h"

@protocol ABNewPersonViewControllerDelegate;

@interface ABNewPersonViewController : UIViewController
{
	id<ABNewPersonViewControllerDelegate> newPersonViewDelegate;
    ABAddressBookRef addressBook;
	ABRecordRef displayedPerson;
	ABRecordRef parentGroup;
}

@property(nonatomic, assign) id<ABNewPersonViewControllerDelegate> newPersonViewDelegate;
@property(nonatomic, readwrite) ABAddressBookRef addressBook;
@property(nonatomic, readwrite) ABRecordRef displayedPerson;
@property(nonatomic, readwrite) ABRecordRef parentGroup;

@end


@protocol ABNewPersonViewControllerDelegate <NSObject>

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person;

@end
