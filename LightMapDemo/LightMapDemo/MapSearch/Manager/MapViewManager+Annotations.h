//
//  MapViewManager+Annotations.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager.h"

@interface MapViewManager (Annotations)
/**
 移除所有的标注
 */
- (void)category_removeAllAnnotations;

/**
 添加标注
 */
- (void)category_addAnnotations;

@end
