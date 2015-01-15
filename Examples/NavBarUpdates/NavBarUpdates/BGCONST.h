#import "UIColor+Extension.h"

#define BG_CELL_SUBTEXT_HEIGHT 14
#define BG_TEXTITLEFRAME CGRectMake(10, 0, 90, 44) // Eg. Account Phone always hardcoded to 90
#define BG_TEXTLABELFRAME CGRectMake(110, 0, self.bounds.size.width-110-40, 44)



#define BG_TITLETAG 100
#define BG_SUBTITLETAG 101


#define BG_PHONE_CELL_TEXT 1000
#define BG_PHONE_CELL_LABEL 1001
#define BG_TEXT_CELL_TEXT 1002
#define BG_TEXT_CELL_LABEL 1003
#define BG_PICKLIST_CELL_TEXT 1004
#define BG_PICKLIST_CELL_LABEL 1005
#define BG_DATE_CELL_TEXT 1006
#define BG_DATE_CELL_LABEL 1007
#define BG_DATETIME_CELL_TEXT 1008
#define BG_DATETIME_CELL_LABEL 1009
#define BG_TEXTAREA_CELL_TEXT 1010
#define BG_TEXTAREA_CELL_LABEL 1011
#define BG_URL_CELL_TEXT 1012
#define BG_URL_CELL_LABEL 1013
#define BG_REFERENCE_CELL_TEXT 1014
#define BG_REFERENCE_CELL_LABEL 1015
#define BG_EMAIL_CELL_TEXT 1016
#define BG_EMAIL_CELL_LABEL 1017
#define BG_CURRENCY_CELL_TEXT 1018
#define BG_CURRENCY_CELL_LABEL 1019
#define BG_MULTIPICKLIST_CELL_TEXT 1020
#define BG_MULTIPICKLIST_CELL_LABEL 1021
#define BG_NUMBER_CELL_TEXT 1022
#define BG_NUMBER_CELL_LABEL 1023
#define BG_COMBOBOX_CELL_TEXT 1024
#define BG_COMBOBOX_CELL_LABEL 1025

#define BG_BOOL_CELL_SWITCH 1026
#define BG_BOOL_CELL_LABEL 1027

#define BG_INVOICE_LINE_CELL_QUANTITY 1028
#define BG_INVOICE_LINE_CELL_TITLE 1029
#define BG_INVOICE_LINE_CELL_DISCOUNT 1030
#define BG_INVOICE_LINE_CELL_AMOUNT 1031

#define BG_QSURVEY_CELL_LABEL 1032
#define BG_QSURVEY_CELL_BUTTON 1033
#define BG_QSURVEY_RESPONSE_LABEL 1034
#define BG_QSURVEY_PICTURE_TF 1035

#define BG_IDEA_TITLETAG 2000
#define BG_IDEA_SUBTITLETAG 2001
#define BG_IDEA_COMMENTS 2002
#define BG_IDEA_RATING 2003



#define BG_ACTIVITY_TITLETAG 2000
#define BG_ACTIVITY_SUBTITLETAG 2001
#define BG_ACTIVITY_ICONTAG 2002



#define BG_PHOTO_TITLETAG 2004
#define BG_PHOTO_SUBTITLETAG 2005
#define BG_PHOTO_DATE 2006


#define BG_PARTNERSHIP_ACCOUNTNAME 99
#define BG_PARTNERSHIP_NAME 100
#define BG_PARTNERSHIP_COMMITTED 2029
#define BG_PARTNERSHIP_PAID 2030
#define BG_PARTNERSHIP_STATUS 2008


#define BG_PAYMENT_PARTNERSHIPNAME 2009
#define BG_PAYMENT_NAME 2010
#define BG_PAYMENT_AMOUNT 2011
#define BG_PAYMENT_TRANSACTION_DATE 2012

#define BG_INVOICE_ACCOUNTNAME 2013
#define BG_INVOICE_NAME 2014
#define BG_INVOICE_STATUS 2015
#define BG_INVOICE_DESCRIPTION 2016
#define BG_INVOICE_VALUE 2017





#define BG_LINEITEM_NAME 2018
#define BG_LINEITEM_AMOUNT 2019
#define BG_LINEITEM_QTY 2020

#define BG_HOME_LABEL 2021

#define BG_USER_TITLETAG 2022
#define BG_USER_NICKNAMETAG 2023
#define BG_USER_STATUS 2024

#define BG_ACCOUNT_TITLETAG 2025
#define BG_ACCOUNT_SUBTITLETAG 2026

#define BG_CONTACT_TITLETAG 2024
#define BG_CONTACT_SUBTITLETAG 2025
#define BG_CONTACT_SUBSUBTITLETAG 2026


#define BG_CHECKIN_TITLETAG 2027
#define BG_CHECKIN_SUBTITLETAG 2028
#define BG_CHECKIN_DATETAG 2029
#define BG_CHECKIN_TIMETAG 2030

#define BG_FEED_TITLETAG 2031
#define BG_FEED_BODYTAG 2032
#define BG_FEED_LINETAG 2033

#define BG_FOLLOW_TITLETAG 2034
#define BG_FOLLOW_LABELTAG 2035
#define BG_FOLLOW_PPL_TAG 2036
#define BG_FOLLOW_RECORDS_TAG 2038
#define BG_FOLLOW_TOTAL_TAG 2040
#define BG_FOLLOWING_TOTAL_TAG 2041

#define BG_TASK_WHAT_TAG 2026
#define BG_TASK_TITLETAG 2027
#define BG_TASK_SUBTITLETAG 2028
#define BG_TASK_DATETAG 2029
#define BG_TASK_TIMETAG 2030

#define BG_CHECK_TAG 20260
#define BG_FACE_CHECK_TAG 20270
#define BG_ACTUAL_TAG 20280
#define BG_OOS_TAG 202701


#define BG_WHAT_TAG 20261
#define BG_DATETAG 20291
#define BG_TIMETAG 20301
#define BG_DURATIONTAG 20311


#define BG_CASE_TYPE 2031
#define BG_CASE_SUBJECT 2032
#define BG_CASE_STATUS 2033
#define BG_CASE_DESCRIPTION 2034
#define BG_CONTACT 2035

#define DISCLOSURE_INDICATOR 999

#define BG_MAJOR_TITLETAG 99
#define BG_TITLETAG 100

//Colors
#define DARKBLUETEXT [UIColor colorWithRed:0.165 green:0.220 blue:0.459 alpha:1.000]
#define DARKBLACKTEXT [UIColor colorWithRed:0.216 green:0.251 blue:0.302 alpha:1.000]
#define IOS7HEADERTITLECOLOR [UIColor colorFromHexString:@"4f4f4f"]
#define IOS7HEADERCOLOR [UIColor colorFromHexString:@"f8f8f8"]
#define DARKGREYTEXT [UIColor colorWithWhite:0.459 alpha:1.000]
#define IOSMAILBLUE [UIColor colorWithRed:0.141 green:0.439 blue:0.847 alpha:1.000]
#define IOS7BLUE [UIColor colorWithRed:0.082 green:0.490 blue:0.984 alpha:1.000]
#define IOS7RED [UIColor colorFromHexString:@"ff3c30"]
#define IOS7ORANGE [UIColor colorFromHexString:@"fd9426"]
#define IOS7GREEN [UIColor colorFromHexString:@"53d769"]
#define GREYLINE [UIColor colorWithRed:0.745 green:0.745 blue:0.753 alpha:1.000]
#define IOS7SELECTEDGRAY [UIColor colorWithWhite:0.820 alpha:1.000]
#define IOS7DETAILABEL [UIColor colorWithWhite:0.537 alpha:1.000]

#define FLAVAGREEN [UIColor colorWithRed:0.459 green:0.671 blue:0.176 alpha:1.000]
#define FLAVA_PURPLE [UIColor colorWithRed:0.659 green:0.396 blue:0.804 alpha:1.000]
#define FLAVA_GREEN0 [UIColor colorWithRed:0.525 green:0.718 blue:0.235 alpha:1.000]
#define FLAVA_BLUE0 [UIColor colorWithRed:0.255 green:0.533 blue:0.941 alpha:1.000]
#define FLAVA_BLUE1 [UIColor colorWithRed:0.255 green:0.533 blue:0.841 alpha:1.000]
#define FLAVA_YELLOW0 [UIColor colorWithRed:0.992 green:0.667 blue:0.161 alpha:1.000]
#define FLAVA_TEAL [UIColor colorWithRed:0.133 green:0.612 blue:0.675 alpha:1.000]
#define FLAVA_LILAC [UIColor colorWithRed:0.337 green:0.439 blue:0.635 alpha:1.000]
#define FLAVA_LIGHT_LILAC [UIColor colorWithRed:0.631 green:0.737 blue:0.808 alpha:1.000]
#define FLAVA_RED [UIColor colorWithRed:0.847 green:0.318 blue:0.243 alpha:1.000]
#define FLAVA_GREY [UIColor colorWithRed:0.667 green:0.694 blue:0.718 alpha:1.000]

#define ALPHABLACK [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5]
//#ifdef LOREAL
#define GRAYTHEME [UIColor colorWithRed:0.639 green:0.663 blue:0.690 alpha:1.000]
//#define GRAYTHEME [UIColor colorWithRed:0.298 green:0.333 blue:0.369 alpha:1.000]
#define GRAY_BUTTON_COLOR [UIColor colorFromHexString:@"646464"]

#define FIELDSTORM_BLUE [UIColor colorWithRed:0.667 green:0.694 blue:0.718 alpha:1.000]//[UIColor colorWithRed:0.000 green:0.588 blue:0.847 alpha:1.000]
#define BG_COLOR [UIColor colorWithWhite:0.208 alpha:1.000]
#define BG_FOOTER [UIColor colorWithWhite:0.275 alpha:1.000]
#define BG_ACTION_COLOR [UIColor colorWithWhite:0.275 alpha:1.000]
#define BG_EXITCALL_COLOR [UIColor colorWithWhite:0.392 alpha:1.000]
#define BG_SEPARATOR_COLOR  [UIColor colorWithWhite:0.392 alpha:1.000]
#define BG_GRID_COLOR  [UIColor whiteColor]

#define VIEWBOUNDS_H self.view.bounds.size.height
#define VIEWBOUNDS_W self.view.bounds.size.width






#define BG_BUTTON_SIZE 14
#define GALLERYMODE 0



#define USER_TITLETAG 104
#define USER_SUBTITLETAG 105
#define FEED_TIME_TAG 106
#define COMMENTS_TAG 107
#define LIKES_TAG 108
#define CELL_IMAGE_BG 110
#define CELL_UP_ARROW 111

#define CELL_TOP 0
#define CELL_MID 1
#define CELL_BOTTOM 2
#define CELL_SINGLE 3


#define UNDEFINED_FOLLOW -1
#define FOLLOW 1
#define UNFOLLOW 2
#define CIRCULARFOLLOW 3


#define TOOLVIEW_HEIGHT 90

#define kCurrentlyCheckedIn @"kCurrentlyCheckedIn"
#define kStoreId @"kStoreId"
#define kRoutePlanId @"kRoutePlanId"
#define kRouteLineItemId @"kRouteLineItemId"
#define kSelectedPoint @"kSelectedPoint"
  
#define kRefreshTaskAndEntity @"kRefreshTaskAndEntity"
#define kSurveyFinishedRefreshTaskAndEntity @"kSurveyFinishedRefreshTaskAndEntity"

#define kSurvey @"FieldStorm__ATT01__c"
#define kShareOfShelf @"FieldStorm__ATT03__c"
#define kPhoto @"FieldStorm__ATT04__c"
#define kStoreAudit @"FieldStorm__ATT10__c"


#define BGBOUNDSWIDTH self.view.bounds.size.width
#define BGBOUNDSHEIGHT self.view.bounds.size.height

