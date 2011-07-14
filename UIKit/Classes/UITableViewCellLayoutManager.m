#import "UITableViewCellLayoutManager.h"
//#import "UITableViewCell.h"
//#import "UIView.h"
//#import "UIImage.h"
//#import "UIImageView.h"
//#import "UILabel.h"

#define CGRectEmpty CGRectMake(0.0, 0.0, 0.0, 0.0)

@implementation UITableViewCellLayoutManager

+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style
{
    switch (style) {
        case UITableViewCellStyleDefault:
            return [[UITableViewCellLayoutManagerDefault alloc] init];
        case UITableViewCellStyleValue1:
        case UITableViewCellStyleValue2:
        case UITableViewCellStyleSubtitle:
            NSLog(@"WARNING: There is currently no UITableViewCellLayoutManager for this UITableViewCellStyle");
            return nil;
    }
    return nil;
}

- (CGRect) contentViewRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty;
}

- (CGRect) accessoryViewRectForCell:(UITableViewCell*)cell 
{
    return CGRectEmpty;
}

- (CGRect) backgroundViewRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty;
}

- (CGRect) seperatorViewRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty;
}

- (CGRect) imageViewRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty;
}

- (CGRect) textLabelRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty; 
}

- (CGRect) detailTextLabelRectForCell:(UITableViewCell*)cell
{
    return CGRectEmpty; 
}

@end



@interface UITableViewCellLayoutManagerDefault (Private)

- (CGFloat) _accessoryViewPaddingForCell:(UITableViewCell*)cell;

@end

@implementation UITableViewCellLayoutManagerDefault


- (CGRect) contentViewRectForCell:(UITableViewCell*)cell
{
    // Collect pertinent information
    CGRect accessoryRect = [self accessoryViewRectForCell:cell];
    CGRect seperatorRect = [self seperatorViewRectForCell:cell];
    CGFloat accessoryPadding = [self _accessoryViewPaddingForCell:cell];
    
    // Width will be 
    CGRect contentRect = {
        .origin = {
            .x = 0,
            .y = 0
        },
        .size = {
            .width = cell.bounds.size.width - accessoryRect.size.width - accessoryPadding,
            .height = cell.bounds.size.height - seperatorRect.size.height
        }
    };
    
    return contentRect;
}

- (CGFloat) _accessoryViewPaddingForCell:(UITableViewCell*)cell
{
    UIView* accessoryView = cell.accessoryView;
    if (nil == accessoryView) {
        return 0.0;
    }

    // NOTE: We can do this only because the SIZE of the accessory view
    // never changes, even though the origin might.
    CGSize accessorySize = cell.accessoryView.bounds.size;
    CGRect cellBounds = cell.bounds;
    CGRect seperatorRect = [self seperatorViewRectForCell:cell];
    
    // Padding is ALWAYS 10 px on the left, but is the LESSER 
    // (including negative numbers) of 10.0 or the height difference,
    // on the right, top, and bottom
    CGFloat heightDifference = floor((cellBounds.size.height - seperatorRect.size.height - accessorySize.height) / 2.0);
    
    return heightDifference < 10.0 ? heightDifference : 10.0;
}

- (CGRect) accessoryViewRectForCell:(UITableViewCell*)cell
{
    UIView* accessoryView = cell.accessoryView;
    CGRect seperatorRect = [self seperatorViewRectForCell:cell];
    CGRect cellBounds = {
        .origin = cell.bounds.origin,
        .size = {
            .width = cell.bounds.size.width,
            .height = cell.bounds.size.height - seperatorRect.size.height
        }
    };
    
    // Custom accessory view always wins
    if (nil != accessoryView) {
        if (nil == accessoryView) {
            return CGRectEmpty;
        }
        else {
            CGSize accessorySize = [accessoryView sizeThatFits:cellBounds.size];
            
            // Provide a rect from the right-hand side of the cell,
            // with the frame centered in the cell

            CGFloat tbr_padding = [self _accessoryViewPaddingForCell:cell];
            CGRect accessoryRect = {
                .origin = {
                    .x = cellBounds.size.width - accessorySize.width - tbr_padding,
                    .y = round((cellBounds.size.height - accessorySize.height) / 2.0),
                },
                .size = accessorySize
            };
            return accessoryRect;
        }
    }
    
    switch (cell.accessoryType) {
        case UITableViewCellAccessoryNone: {
            return CGRectEmpty;
            break;
        }
        
        case UITableViewCellAccessoryCheckmark:
        case UITableViewCellAccessoryDisclosureIndicator:
        case UITableViewCellAccessoryDetailDisclosureButton: {
            
            // Hard-coded widths, from the iphone
            CGFloat width = 20.0;
            if (cell.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
                width = 33.0;
            }
            
            CGSize accessorySize = {
                .width = width,
                .height = cellBounds.size.height
            };
            CGRect accessoryRect = {
                .origin = {
                    .x = cellBounds.size.width - accessorySize.width,
                    .y = 0.0,
                },
                .size = accessorySize
            };
            
            return accessoryRect;
            break;
        }
        
        default: {
            return CGRectEmpty;
            break;
        }
    }
    
    return CGRectEmpty;
}

- (CGRect) backgroundViewRectForCell:(UITableViewCell*)cell
{
    if (nil != cell.backgroundView) {
        CGRect seperatorRect = [self seperatorViewRectForCell:cell];
        CGRect backgroundRect = {
            .origin = {
                .x = 0,
                .y = 0
            },
            .size = {
                .width = cell.bounds.size.width,
                .height = cell.bounds.size.height - seperatorRect.size.height
            }
        };
        return backgroundRect;
    }
    else {
        return CGRectEmpty;
    }
}

- (CGRect) seperatorViewRectForCell:(UITableViewCell*)cell
{
    CGRect seperatorRect = {
        .origin = {
            .x = 0,
            .y = cell.bounds.size.height - 1.0,
        },
        .size = {
            .width = cell.bounds.size.width,
            .height = 1.0,
        }
    };
    return seperatorRect;
}

- (CGRect) imageViewRectForCell:(UITableViewCell*)cell
{
    UIImageView* imageView = cell.imageView;
    UIImage* image = imageView.image;
    if (nil == imageView || nil == imageView.image) {
        return CGRectEmpty;
    }
    
    // Allows a maximum height of (cell.bounds.height - 1) pixels. 
    // If the image size is less, apply a padding that + image height = cell.bounds.height px 
    // THE IMAGE HEIGHT IS NEVER CONSTRAINED (tested in iOS)
    CGSize imageSize = image.size;
    CGRect cellBounds = cell.bounds;
    CGRect seperatorRect = [self seperatorViewRectForCell:cell];
    CGFloat maxHeight = cellBounds.size.height - seperatorRect.size.height;
    
    if (imageSize.height < maxHeight) {
        // Image is not as tall as the cell
        CGFloat padding = floor((maxHeight - imageSize.height) / 2.0);
        CGRect imageViewRect = {
            .origin = {
                .x = padding < 0 ? 0 : padding,
                .y = padding
            },
            .size = imageSize
        };
        return imageViewRect;
    }
    else if (imageSize.height == maxHeight) {
        // Image height == cell height
        CGRect imageViewRect = {
            .origin = {
                .x = 0,
                .y = 0
            },
            .size = imageSize,
        };
        return imageViewRect;
    }
    else {
        // Image is taller than the cell
        CGFloat differencePercent = (maxHeight / imageSize.height);
        CGRect imageViewRect = {
            .origin = {
                .x = 0,
                .y = 0
            },
            .size = {
                .width = round(imageSize.width * differencePercent),
                .height = round(imageSize.height * differencePercent),
            }
        };
        return imageViewRect;
    }
}

- (CGRect) textLabelRectForCell:(UITableViewCell*)cell
{
    UILabel* textLabel = cell.textLabel;
    if (nil == textLabel) {
        return CGRectEmpty;
    }
        
    // RULES
    // =======
    // 10 pixel padding from the image rect or if no image rect, 10 pixel in
    // origin.x is at max 10 pixels less than the content frame right bound

    // origin.y always == 0
    // size.height always == contentRect.size.height
    
    // The allowable width is always from the right side of the content rect - 10 (padding)
    // to the greater of the end of the content rect OR the final bounds of the image view - 10 (padding)

    CGRect contentRect = [self contentViewRectForCell:cell];
    CGRect imageRect = [self imageViewRectForCell:cell];
    
    CGFloat originX = 0.0;
    CGFloat width = 0.0;
    
    CGFloat maxXOrigin = contentRect.size.width - 10.0;
    CGFloat imageRectLastX = imageRect.origin.x + imageRect.size.width + 10.0;
    
    if (imageRectLastX > maxXOrigin) {
        originX = maxXOrigin; 
        width = imageRectLastX - maxXOrigin;
    }
    else {
        originX = imageRectLastX;
        width = contentRect.size.width - originX - 10.0;
    }
    
    CGRect textLabelRect = {
        .origin = {
            .x = originX,
            .y = 0
        },
        .size = {
            .width = width,
            .height = contentRect.size.height
        }
    };
    
    return textLabelRect;
}


@end