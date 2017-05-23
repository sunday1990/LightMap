//
//  MapViewManager+Annotations.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager+Annotations.h"

@implementation MapViewManager (Annotations)
- (void)category_removeAllAnnotations{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)category_addAnnotations{
    NSInteger count = self.searchKeyModel.resultArray.count;
    for (int i = 0; i<count; i++) {
        BMKPointAnnotation *annotation = [self.searchKeyModel.resultArray objectAtIndex:i];//annotation模型可以为自定义的
        [self.mapView addAnnotation:annotation];
    }
}


@end
