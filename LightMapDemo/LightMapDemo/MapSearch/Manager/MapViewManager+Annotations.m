//
//  MapViewManager+Annotations.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager+Annotations.h"
#import "MapBasePolygon.h"

@implementation MapViewManager (Annotations)
- (void)category_removeAllAnnotations{
    [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.mapView.overlays.count>0) {
        [self.mapView removeOverlays:self.mapView.overlays];
    }
}

- (void)category_addAnnotations{
    NSInteger count = self.searchKeyModel.resultArray.count;
    for (int i = 0; i<count; i++) {
        BMKPointAnnotation *annotation = [self.searchKeyModel.resultArray objectAtIndex:i];//annotation模型可以为自定义的
        [self.mapView addAnnotation:annotation];
    }
    [self addMapPolygons];
}

- (void)addMapPolygons{
    /*添加底部阴影区域*/
    CLLocationCoordinate2D * coors0 = (CLLocationCoordinate2D *)malloc(4 * sizeof(CLLocationCoordinate2D));
    coors0[0].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[0].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    coors0[1].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors0[1].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    coors0[2].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors0[2].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    coors0[3].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[3].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    BMKPolygon *polygonModel0 = [BMKPolygon polygonWithCoordinates:coors0 count:4];
    [self.mapView addOverlay:polygonModel0];
    /*
     
     <MapNetWorkManager.m:102> 名称：大兴区-----lat:39.73207700000000000-----lng:116.34860600000000000
     <MapNetWorkManager.m:102> 名称：顺义区-----lat:40.13568400000000000-----lng:116.66121500000000000
     <MapNetWorkManager.m:102> 名称：长宁区-----lat:31.21218500000000000-----lng:121.39556100000000000
     <MapNetWorkManager.m:102> 名称：朝阳区-----lat:39.95790600000000000-----lng:116.53146800000000000
     <MapNetWorkManager.m:102> 名称：通州区-----lat:39.91501800000000000-----lng:116.66286700000000000
     <MapNetWorkManager.m:102> 名称：海淀区-----lat:40.00966900000000000-----lng:116.28248000000000000
     <MapNetWorkManager.m:102> 名称：东城区-----lat:39.92362200000000000-----lng:116.41934400000000000
     <MapNetWorkManager.m:102> 名称：昌平区-----lat:40.22525400000000000-----lng:116.23789100000000000
     <MapNetWorkManager.m:102> 名称：西城区-----lat:39.91229800000000000-----lng:116.36463200000000000
     <MapNetWorkManager.m:102> 名称：丰台区-----lat:39.84195800000000000-----lng:116.27251700000000000
     */
    CLLocationCoordinate2D * coors1 = (CLLocationCoordinate2D *)malloc(5 * sizeof(CLLocationCoordinate2D));
    coors1[0].longitude = 116.28248 ;
    coors1[0].latitude = 40.0096690;
    coors1[1].longitude = 116.272517;
    coors1[1].latitude = 39.841958;
    coors1[2].longitude = 116.348606;
    coors1[2].latitude = 39.732077;
    coors1[3].longitude = 116.531468;
    coors1[3].latitude = 39.957906;
    coors1[4].longitude = 116.419344;
    coors1[4].latitude = 39.923622;

    MapBasePolygon *polygonModel = [[MapBasePolygon alloc] init];
    
    [polygonModel polygonWithCoords:coors1 count:5];
    
    [self.mapView addOverlay:polygonModel];
}


@end
