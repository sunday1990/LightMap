//
//  MapViewManager.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <MJExtension/MJExtension.h>
#import "Constant_Basic.h"
#import "MapSearchKeyModel.h"
#import <Aspects/Aspects.h>

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
 经纬度数组
 */
@property (nonatomic,strong)NSMutableArray *locationArray;

/**
 移除标注
 */
- (void)removeAllAnnotations;

/**
 添加标注
 */
- (void)addAnnotations;


/**
 隐藏百度地图的logo
 */
- (void)hideBaiduMapLogo;

/**
 显示百度地图的logo
 */
- (void)showBaiduMapLogo;
/**
 阻尼效果改变地图等级
 
 @param currentLevel  当前的等级
 @param settingLevel  要设定的等级
 */
- (void)dampZoomingMapLevelFromCurrentValue:(float)currentLevel
                             ToSettingValue:(float)settingLevel;

/**
 开启地图惯性缩放

 @param inertiaCoefficient 惯性系数，系数越小，惯性越小，越容易改变，系数越大，惯性越大，越不容易改变

 */
- (void)openMapInertiaDragWithCoefficient:(float)inertiaCoefficient;

/**
 关闭地图惯性缩放
 */
- (void)cloaseMapInertialDrag;

@end
