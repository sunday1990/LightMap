//
//  UIView+frame.m
//  tennisApp
//
//  Created by ESAY on 14-12-17.
//  Copyright (c) 2014年 ESAY. All rights reserved.
//

#import "UIView+frame.h"

@implementation UIView (frame)

- (void)setWidth:(CGFloat)width
{
    CGSize size =CGSizeMake(width, self.frame.size.height);
    self.frame =CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}
- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGSize size =CGSizeMake(self.frame.size.width, height);
    self.frame =CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}
- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setOriginX:(CGFloat)originX
{
    CGPoint point = CGPointMake(originX, self.frame.origin.y);
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)originX
{
    return self.frame.origin.x;
}

- (void)setOriginY:(CGFloat)originY
{
    CGPoint point = CGPointMake(self.frame.origin.x, originY);
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)originY
{
    return self.frame.origin.y;
}

- (void) makeCorner:(float)r {
    if (r < 0) r = 0;
    self.layer.cornerRadius = r;
    self.layer.masksToBounds = YES;
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)left{
    [self setX:left];
}

- (CGFloat)left{
    return self.x;
}

- (void)setTop:(CGFloat)top{
    [self setY:top];
}

- (CGFloat)top{
    return self.y;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

@end
