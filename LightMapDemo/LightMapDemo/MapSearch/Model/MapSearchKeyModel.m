//
//  MapSearchKeyModel.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapSearchKeyModel.h"
#import <MJExtension/MJExtension.h>

@interface MapSearchKeyModel ()
/**
 存放需要剔除掉的字段
 */
@property (nonatomic, strong)NSMutableArray *filterArray;

@end

@implementation MapSearchKeyModel

- (NSString *)price_max{
    if (!_price_max) {
        return @"-1";
    }
    return _price_max;
}

- (NSString *)price_min{
    if (!_price_min) {
        return @"-1";
    }
    return _price_min;
}

- (NSString *)area_max{
    if (!_area_max) {
        return @"-1";
    }
    return _area_max;
}

- (NSString *)area_min{
    if (!_area_min) {
        return @"-1";
    }
    return _area_min;
}

- (NSString *)typeID{

    if (!_typeID) {
        return @"1";
    }
    return _typeID;
}

- (NSString *)level{
    if (!_level) {
        return @"1";
    }
    return _level;
}


- (NSMutableArray *)filterArray{
    if (!_filterArray) {
        _filterArray = [NSMutableArray arrayWithObjects:@"uploadParam",@"coordinateRange",@"resultArray",nil];
    }
    return _filterArray;
}

- (NSMutableArray *)resultArray{
    if (!_resultArray) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

/**
 设置区域范围，获取左下与右上的坐标
 
 @param coordinateRange
 */
- (void)setCoordinateRange:(BMKCoordinateRegion)coordinateRange{
    float deta = 0.0;//1.1/dl;
    coordinateRange.span.longitudeDelta *= (1+deta);
    coordinateRange.span.latitudeDelta *= (1+deta);
    double latDel = coordinateRange.span.latitudeDelta/2.0;
    double lngDel = coordinateRange.span.longitudeDelta/2.0;
    double centerLat = coordinateRange.center.latitude;
    double centerLng = coordinateRange.center.longitude;
    self.zxlng = [[NSString alloc] initWithFormat:@"%f",(centerLng-lngDel)];
    self.zxlat = [[NSString alloc] initWithFormat:@"%f",(centerLat-latDel)];
    self.yslng = [[NSString alloc] initWithFormat:@"%f",(centerLng+lngDel)];
    self.yslat = [[NSString alloc] initWithFormat:@"%f",(centerLat+latDel)];
}

- (NSDictionary *)searchKeyModel_getRequestParams{
    self.uploadParam = [self mj_JSONObject];
    for(NSString *key in self.uploadParam.allKeys){
        if ([self.filterArray containsObject:key]) {
            [self.uploadParam removeObjectForKey:key];
        }
    }
    return self.uploadParam;
}
@end
