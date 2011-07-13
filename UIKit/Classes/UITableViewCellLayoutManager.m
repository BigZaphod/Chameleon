#import "UITableViewCellLayoutManager.h"
#import "UITableViewCell.h"
#import "UIView.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UILabel.h"

@implementation UITableViewCellLayoutManager

+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style
{
    switch (style) {
        case UITableViewCellStyleDefault:
            return [[UITableViewCellLayoutManagerDefault alloc] init];
        case UITableViewCellStyleValue1:
        case UITableViewCellStyleValue2:
        case UITableViewCellStyleSubtitle:
            return nil;
    }
    return nil;
}

- (CGRect) contentRectForCell:(UITableViewCell*)cell
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull;
}

- (CGRect) accessoryRectForCell:(UITableViewCell*)cell 
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull;
}

- (CGRect) backgroundRectForCell:(UITableViewCell*)cell
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull;
}

- (CGRect) seperatorRectForCell:(UITableViewCell*)cell
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull;
}

- (CGRect) imageViewRectForCell:(UITableViewCell*)cell
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull;
}

- (CGRect) textLabelRectForCell:(UITableViewCell*)cell
{
    [NSException raise:@"NotImplementedException" 
                format:@"This method has to be called from a subclass of UITableViewCellLayoutManager"];
    return CGRectNull; 
}

@end


@implementation UITableViewCellLayoutManagerDefault


- (CGRect) contentRectForCell:(UITableViewCell*)cell
{
    // Collect pertinent information
    CGRect accessoryRect = [self accessoryRectForCell:cell];
    CGRect seperatorRect = [self seperatorRectForCell:cell];
    
    // Width will be 
    CGRect contentRect = {
        .origin = {
            .x = 0,
            .y = 0
        },
        .size = {
            .width = cell.bounds.size.width - accessoryRect.size.width,
            .height = cell.bounds.size.height - seperatorRect.size.height
        }
    };
    
    return contentRect;
}

- (CGRect) accessoryRectForCell:(UITableViewCell*)cell
{
    CGRect cellBounds = cell.bounds;
    
    switch (cell.accessoryType) {
        case UITableViewCellAccessoryNone: {
            return CGRectNull;
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
            UIView* accessoryView = cell.accessoryView;
            if (nil == accessoryView) {
                return CGRectNull;
            }
            else {
                CGSize accessorySize = [accessoryView sizeThatFits:cellBounds.size];
                
                // Provide a rect from the right-hand side of the cell,
                // with the frame centered in the cell
                CGRect accessoryRect = {
                    .origin = {
                        .x = cellBounds.size.width - accessorySize.width,
                        .y = floor((cellBounds.size.height - accessorySize.height) / 2.0),
                    },
                    .size = accessorySize
                };
                return accessoryRect;
            }
        }
    }
    
    return CGRectNull;
}

- (CGRect) backgroundRectForCell:(UITableViewCell*)cell
{
    if (nil != cell.backgroundView) {
        return cell.bounds;
    }
    else {
        return CGRectNull;
    }
}

- (CGRect) seperatorRectForCell:(UITableViewCell*)cell
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
    if (nil == imageView) {
        return CGRectNull;
    }
    
    // Allows a maximum height of (cell.bounds.height - 1) pixels. 
    // If the image size is less, apply a padding that + image height = cell.bounds.height px 
    // THE IMAGE HEIGHT IS NEVER CONSTRAINED (tested in iOS)
    UIImage* image = imageView.image;
    CGSize imageSize = image.size;
    CGRect cellBounds = cell.bounds;
    CGFloat maxHeight = cellBounds.size.height - 1.0;
    
    if (imageSize.height < maxHeight) {
        // Image is not as tall as the cell
        CGFloat padding = round((maxHeight - cellBounds.size.height) / 2.0);
        CGRect imageViewRect = {
            .origin = {
                .x = padding,
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
                .width = floor(imageSize.width * differencePercent),
                .height = floor(imageSize.height * differencePercent),
            }
        };
        return imageViewRect;
    }
}

- (CGRect) textLabelRectForCell:(UITableViewCell*)cell
{
    UILabel* textLabel = cell.textLabel;
    if (nil == textLabel) {
        return CGRectNull;
    }
    
    CGRect contentRect = [self contentRectForCell:cell];
    CGRect imageRect = [self imageViewRectForCell:cell];
    
    // If the text label is larger height-wise than the cell, the frame
    // is returned as origin.y = 0, height = contentView.bounds.height
    CGSize originalSize = textLabel.bounds.size;
    CGFloat calculatedHeight = 0.0;

    if (originalSize.height > contentRect.size.height) {
        calculatedHeight = contentRect.size.height;
    }
    else {
        calculatedHeight = originalSize.height;
    }
    
    // 10 pixel padding from the image rect or if no image rect, 10 pixel in
    CGPoint origin = {
        .x = imageRect.origin.x + imageRect.size.width + 10.0,
        .y = floor((contentRect.size.height - calculatedHeight) / 2.0)
    };

    CGRect textLabelRect = {
        .origin = origin,
        .size = {
            .width = contentRect.size.width - imageRect.size.width - 10.0,
            .height = calculatedHeight
        }
    };
    
    return textLabelRect;
}


@end