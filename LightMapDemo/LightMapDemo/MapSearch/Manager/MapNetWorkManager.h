//
//  MapNetWorkManager.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MapSearchKeyModel.h"

FOUNDATION_EXPORT NSString * const MapViewShouldRemoveAllAnnotations;

@interface MapNetWorkManager : NSObject
/**
 请求数据，keyModel里面有我们想要的数组，因此success里不带参数
 
 @param searchKeyModel searchKeyModel description
 @param successCallBack successCallBack description
 @param failureCallBack failureCallBack description
 */
+ (void)managerRequestMapDetailWithModel:(MapSearchKeyModel *)searchKeyModel Success:(void(^)())successCallBack Failure:(void(^)(NSError *error))failureCallBack;

@end
