//
//  FLEXColor.h
//  FLEX
//
//  Created by Benny Wong on 6/18/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue, alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FLEX)
- (UIColor *)inverseColor;
@end

@interface FLEXColor : NSObject

@property (readonly, class) UIColor *primaryBackgroundColor;
+ (UIColor *)primaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *secondaryBackgroundColor;
+ (UIColor *)secondaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *tertiaryBackgroundColor;
+ (UIColor *)tertiaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *groupedBackgroundColor;
+ (UIColor *)groupedBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *secondaryGroupedBackgroundColor;
+ (UIColor *)secondaryGroupedBackgroundColorWithAlpha:(CGFloat)alpha;

// Text colors
@property (readonly, class) UIColor *primaryTextColor;
@property (readonly, class) UIColor *deemphasizedTextColor;

// UI element colors
@property (readonly, class) UIColor *tintColor;
@property (readonly, class) UIColor *scrollViewBackgroundColor;
@property (readonly, class) UIColor *iconColor;
@property (readonly, class) UIColor *borderColor;
@property (readonly, class) UIColor *toolbarItemHighlightedColor;
@property (readonly, class) UIColor *toolbarItemSelectedColor;
@property (readonly, class) UIColor *hairlineColor;
@property (readonly, class) UIColor *destructiveColor;

@end

NS_ASSUME_NONNULL_END
