//
//  UIView+frame.h
//  tennisApp
//
//  Created by ESAY on 14-12-17.
//  Copyright (c) 2014年 ESAY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)

@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,assign)CGFloat originX;
@property(nonatomic,assign)CGFloat originY;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
- (void) makeCorner:(float)r;

@end
