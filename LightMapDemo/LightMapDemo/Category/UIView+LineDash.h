//
//  UIView+LineDash.h
//  SpaceHome
//
//  Created by suhc on 2016/11/3.
//
//

#import <UIKit/UIKit.h>

@interface UIView (LineDash)

/**
 *  添加虚线边框
 *
 *  @param borderWidth 边框宽度
 *  @param dashPattern @[@有色部分的宽度,@无色部分的宽度]
 *  @param color   虚线颜色
 */
- (void)addBorderDashLineWithBorderWidth:(CGFloat)borderWidth dashPattern:(NSArray<NSNumber *> *)dashPattern color:(UIColor *)color;

- (void)popupAnimationWithDuration:(CFTimeInterval)duration;

- (void)popupAnimationWithDuration:(CFTimeInterval)duration
                    animationValue:(NSArray <NSNumber *>*)values
                 animationKeyTimes:(NSArray <NSNumber *>*)keyTimes;

- (void)popupAnimationWithDuration:(CFTimeInterval)duration
                    animationValue:(NSArray <NSNumber *>*)values
                 animationKeyTimes:(NSArray <NSNumber *>*)keyTimes
                 animationFinished:(void(^)())animationFinished;

- (void)dismissAnimationWithDuration:(CFTimeInterval)duration
                    animationValue:(NSArray <NSNumber *>*)values
                 animationKeyTimes:(NSArray <NSNumber *>*)keyTimes
                 animationFinished:(void(^)())animationFinished;


@end
