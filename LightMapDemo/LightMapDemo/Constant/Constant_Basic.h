//
//  Constant_Basic.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#ifndef Constant_Basic_h
#define Constant_Basic_h
/***************************** Key  *****************************/

#define BaiduMapKey @"2rSt1TUqOEaV099BeGnEW0Vku4VGRmNL"

/***************************** 尺寸  *****************************/
#define WIDTH  ([[UIScreen mainScreen]bounds].size.width)
#define HEIGHT ([[UIScreen mainScreen]bounds].size.height)
#define UI_NAV_BAR_HEIGHT  (SYSTEM_VERSION < 7 ? 44:64)
#define UI_TAB_BAR_HEIGHT  49
#define UI_STATUS_BAR_HEIGHT (SYSTEM_VERSION < 7 ? 0:20)
#define SYSTEM_VERSION ([[UIDevice currentDevice].systemVersion floatValue])
#define PADDING     12

/***************************** 便捷方法  *****************************/

#define GetColor(color) [UIColor color]
#define GetImage(imageName)  [UIImage imageNamed:imageName]
#define GetFont(x) [UIFont systemFontOfSize:x]
#define WEAK(object)        __weak typeof(object) weak##object = object;
#define BLOCK(object)       __block typeof(object) block##object = object;
#define STRONG(object)     __strong __typeof(object)strongSelf = object;
//提示框--->UIAlertController
#define ALERT_VIEW(Title,Message,Controller) {UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Title message:Message preferredStyle:UIAlertControllerStyleAlert];        [alertVc addAction:action];[Controller presentViewController:alertVc animated:YES completion:nil];}


/***************************** 快速创建单例  *****************************/
#define singletonInterface(className)          + (instancetype)shared##className;
// 实现定义
// 在定义宏时 \ 可以用来拼接字符串
#define singletonImplementation(className) \
static className *_instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (instancetype)shared##className \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}

#endif /* Constant_Basic_h */
