//
//  BMKMapViewAdapter.h
//  SpaceHome
//
//  Created by ccSunday on 2017/11/27.
//  Copyright © 2017年 kongjianjia.com. All rights reserved.
//  专门处理百度地图运动特性的类

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface BMKMapViewAdapter : NSObject

/**
 
 @param mapView mapView description
 @param inertiaCoefficient inertiaCoefficient description
 */
+ (void)mapView:(BMKMapView *)mapView openInertiaDragWithCoefficient:(float)inertiaCoefficient;


/**


 @param mapView mapView description
 @param close close description
 */
+ (void)mapView:(BMKMapView *)mapView closeMapInertialDrag:(BOOL)close;


/**
 Description

 @param mapView mapView description
 @param currentLevel currentLevel description
 @param settingLevel settingLevel description
 */
+ (void)mapView:(BMKMapView *)mapView dampZoomingMapLevelFromCurrentValue:(float)currentLevel ToSettingValue:(float)settingLevel;


/**
 空置logo的显示与隐藏

 @param mapView mapView description
 @param status status description
 */
+ (void)mapView:(BMKMapView *)mapView setBaiduMapLogoHiddenStatus:(BOOL)status;
@end

