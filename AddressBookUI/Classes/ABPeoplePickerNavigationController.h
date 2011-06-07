//
//  ABPeoplePickerNavigationController.h
//  AddressBookUI
//
//  Copyright (c) 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIkit.h>
#import <AddressBook/ABAddressBookC.h>
#import "AddressBookUI.h"

@protocol ABPeoplePickerNavigationControllerDelegate;

@interface ABPeoplePickerNavigationController : UINavigationController
{
	id<ABPeoplePickerNavigationControllerDelegate> peoplePickerDelegate;
	NSArray *displayedProperties;
	ABAddressBookRef addressBook;
}

@property(nonatomic,assign) id<ABPeoplePickerNavigationControllerDelegate> peoplePickerDelegate;
@property(nonatomic,copy) NSArray *displayedProperties;
@property(nonatomic,readwrite) ABAddressBookRef addressBook;

@end


@protocol ABPeoplePickerNavigationControllerDelegate <NSObject>

    // Called after the user has pressed cancel
    // The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;

    // Called after a person has been selected by the user.
    // Return YES if you want the person to be displayed.
    // Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
    // Called after a value has been selected by the user.
    // Return YES if you want default action to be performed.
    // Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end
