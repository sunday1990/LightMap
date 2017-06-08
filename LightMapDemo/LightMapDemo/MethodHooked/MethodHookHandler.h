//
//  MethodHookHandler.h
//  LightMapDemo
//
//  Created by ccSunday on 2017/5/24.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MethodHookHandler : NSObject

- (void)handler_handleSingleTap;

- (void)handler_handleLongpressGesture:(UILongPressGestureRecognizer *)longGes;

@end
