//
//  MethodHookHandler.m
//  LightMapDemo
//
//  Created by ccSunday on 2017/5/24.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MethodHookHandler.h"

@implementation MethodHookHandler

- (void)handler_handleSingleTap{

    NSLog(@"%@ Method Be Hooked",NSStringFromSelector(_cmd));
}

- (void)handler_handleLongpressGesture:(UILongPressGestureRecognizer *)longGes{

    NSLog(@"%@ Method Be Hooked",NSStringFromSelector(_cmd));
}


@end
