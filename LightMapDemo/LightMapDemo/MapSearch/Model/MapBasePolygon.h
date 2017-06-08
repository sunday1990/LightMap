//
//  MapBasePolygon.h
//  LightMapDemo
//
//  Created by ccSunday on 2017/6/8.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MapBasePolygon : BMKPolygon

/**
 是否是底部的阴影
 */
@property (nonatomic,assign)BOOL isBottomShadow;

- (void )polygonWithCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

@end
