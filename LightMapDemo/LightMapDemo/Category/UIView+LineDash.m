//
//  UIView+LineDash.m
//  SpaceHome
//
//  Created by suhc on 2016/11/3.
//
//

#import "UIView+LineDash.h"

@implementation UIView (LineDash)

- (void)addBorderDashLineWithBorderWidth:(CGFloat)borderWidth dashPattern:(NSArray<NSNumber *> *)dashPattern color:(UIColor *)color {
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = self.bounds;
    borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    borderLayer.lineWidth = borderWidth;
    //虚线边框
    borderLayer.lineDashPattern = dashPattern;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = color.CGColor;
    [self.layer addSublayer:borderLayer];
}

- (void)popupAnimationWithDuration:(CFTimeInterval)duration{
    [self popupAnimationWithDuration:duration animationValue:@[@(0.8), @(1.05), @(1.1), @(1)] animationKeyTimes:@[@(0), @(0.3), @(0.5), @(1.0)]];
}

- (void)popupAnimationWithDuration:(CFTimeInterval)duration animationValue:(NSArray<NSNumber *> *)values animationKeyTimes:(NSArray<NSNumber *> *)keyTimes{

    void(^animationFineshed)();
    
    [self popupAnimationWithDuration:duration animationValue:values animationKeyTimes:keyTimes animationFinished:animationFineshed];

}

- (void)popupAnimationWithDuration:(CFTimeInterval)duration
                    animationValue:(NSArray <NSNumber *>*)values
                 animationKeyTimes:(NSArray <NSNumber *>*)keyTimes
                 animationFinished:(void(^)())animationFinished{

    self.alpha = 0;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        if (animationFinished) {
            animationFinished();
        }
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = values;
        animation.keyTimes = keyTimes;
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        animation.duration = duration;
        [self.layer addAnimation:animation forKey:@"bouce"];
        
    } else {
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:duration * 0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration * 0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration * 0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.transform = CGAffineTransformMakeScale(1, 1);
                } completion:nil];
            }];
        }];
    }
}

- (void)dismissAnimationWithDuration:(CFTimeInterval)duration
                      animationValue:(NSArray <NSNumber *>*)values
                   animationKeyTimes:(NSArray <NSNumber *>*)keyTimes
                   animationFinished:(void(^)())animationFinished{

    self.alpha = 1;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (animationFinished) {
            animationFinished();
        }
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = values;
        animation.keyTimes = keyTimes;
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        animation.duration = duration;
        [self.layer addAnimation:animation forKey:@"bouce"];
    } else {
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:duration * 0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration * 0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration * 0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.transform = CGAffineTransformMakeScale(1, 1);
                } completion:nil];
            }];
        }];
    }


}
@end
