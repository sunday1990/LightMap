//
//  MapViewManager.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "Constant_Basic.h"
#import "MapSearchKeyModel.h"

FOUNDATION_EXPORT NSString * const MapViewDidChangeDesType;

@interface MapViewManager : NSObject
singletonInterface(MapViewManager)

/**
 BaiduMapView
 */
@property(nonatomic,retain)BMKMapView *mapView;
/**
 回到我当前所在位置的按钮
 */
@property(nonatomic,strong)UIButton *currentLocBtn;
/**
 searchKeyModel
 */
@property(nonatomic,weak)MapSearchKeyModel *searchKeyModel;
/**
 以点击点为中心放大地图层级
 
 @param centerCoordinate centerCoordinate description
 */
- (void)changeMapLevelWithTheClickCenter:(CLLocationCoordinate2D)centerCoordinate;

/**
 移除标注
 */
- (void)removeAllAnnotations;

/**
 添加标注
 */
- (void)addAnnotations;

@end
