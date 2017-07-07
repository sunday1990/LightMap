//
//  MapViewManager+Annotations.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//
 /*
 名称：大兴区-----lat:39.73207700000000000-----lng:116.34860600000000000
 名称：顺义区-----lat:40.13568400000000000-----lng:116.66121500000000000
 名称：长宁区-----lat:31.21218500000000000-----lng:121.39556100000000000
 名称：朝阳区-----lat:39.95790600000000000-----lng:116.53146800000000000
 名称：通州区-----lat:39.91501800000000000-----lng:116.66286700000000000
 名称：海淀区-----lat:40.00966900000000000-----lng:116.28248000000000000
 名称：东城区-----lat:39.92362200000000000-----lng:116.41934400000000000
 名称：昌平区-----lat:40.22525400000000000-----lng:116.23789100000000000
 名称：西城区-----lat:39.91229800000000000-----lng:116.36463200000000000
 名称：丰台区-----lat:39.84195800000000000-----lng:116.27251700000000000
 */
#import "MapViewManager+Annotations.h"
#import "MapBasePolygon.h"
#import "TestPolygonModel.h"
#import <SVProgressHUD/SVProgressHUD.h>
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
#pragma mark 程序实现
    /*从self.locationArray中获取数据进行展示，存储的model是TestPolygonModel*/
   
    /*1、获取需要malloc的内存区域，由以下几个部分组成:
     1st:  6个屏幕点
     2st:  self.locationArray.count*2 - 1       计算多边形起点被多加的次数，后面的减一是因为最后一个数组的第一个点只需要多加一遍，其他的都是多加两遍，注意这里计算的是起点被多加的次数，而不是起点被添加的总次数
     3st:  self.locationArray子数组中元素的个数和，self.locationArray存放的是经纬度模型数组。
     */
    NSInteger mallocCount = 0;//需要分配的内存大小，也就是经纬度数组中总共的点数，也就是上面提到的三部分之和
    NSInteger itemCount = 0;  //也就是self.locationArray子数组中经纬度模型的个数和
    NSInteger itemIndex = 0;  //coors下表
    for (int i = 0; i<self.locationArray.count; i++) {
        itemCount = itemCount + [self.locationArray[i] count];
    }
    mallocCount = 6 + self.locationArray.count * 2 - 1 + itemCount;
    /*2、正序计算，无论是不是最后一个数组，先依次将该数组的点加进去，加完后再加一遍该数组中的第一个点。*/
    CLLocationCoordinate2D * coors = (CLLocationCoordinate2D *)malloc(mallocCount * sizeof(CLLocationCoordinate2D));
    /*添加屏幕左下角的S1点*/
    coors[0].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors[0].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*正序添加每一个数组中的所有元素*/
    for (int i = 0; i < self.locationArray.count; i++) {
        NSArray *polygonArray = self.locationArray[i];
        for (int j = 0; j<polygonArray.count; j++) {
            TestPolygonModel *polygonModel = self.locationArray[i][j];                      //获取model
            itemIndex++;
            coors[itemIndex].longitude = [polygonModel.lng floatValue];
            coors[itemIndex].latitude = [polygonModel.lat floatValue];
        }
        //添加完每一组的元素后，需要再添加一遍该组的第一个点，
        itemIndex ++;
        TestPolygonModel *startPolygon = polygonArray[0];
        coors[itemIndex].latitude = [startPolygon.lat floatValue];
        coors[itemIndex].longitude = [startPolygon.lng floatValue];
    }
    
    /*3、倒叙添加每一组的第一个元素，但是最后一个组不需要添加，因为最后一个组总共只需要加两遍，所以过滤掉最后一组*/
    for (NSInteger i = self.locationArray.count - 1; i>0; i--) {
        itemIndex ++;
        TestPolygonModel *startPolygon = self.locationArray[i-1][0];                      //获取model
        coors[itemIndex].latitude = [startPolygon.lat floatValue];
        coors[itemIndex].longitude = [startPolygon.lng floatValue];
    }
    
    /*4、添加屏幕的边界点*/
    /*再次添加屏幕的起点*/
    itemIndex ++;
    coors[itemIndex].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors[itemIndex].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕右下角的S2点*/
    itemIndex ++;
    coors[itemIndex].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors[itemIndex].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕右上角的S3点*/
    itemIndex ++;
    coors[itemIndex].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors[itemIndex].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕左上角的S4点*/
    itemIndex ++;
    coors[itemIndex].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors[itemIndex].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    /*再次添加屏幕左下角的S1点*/
    itemIndex ++;
    coors[itemIndex].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors[itemIndex].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    if (mallocCount == itemIndex+1) {
        BMKPolygon *polygonModel0 = [BMKPolygon polygonWithCoordinates:coors count:mallocCount];
        [self.mapView addOverlay:polygonModel0];
    }else{
        [SVProgressHUD showErrorWithStatus:@"计算错误"];
    }
    return;
    
#pragma mark 非程序实现-没有雾霾
    /*添加底部阴影区域*/
    CLLocationCoordinate2D * coors0 = (CLLocationCoordinate2D *)malloc(17 * sizeof(CLLocationCoordinate2D));
    /*添加屏幕左下角的S1点*/
    coors0[0].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[0].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*添加矩形区域A左下角的A1点*/
    coors0[1].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta/4;
    coors0[1].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta/4;
    /*添加矩形区域A右下角的A2点*/
    coors0[2].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta/4;
    coors0[2].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta/4;
    /*添加矩形区域A右上角的A3点*/
    coors0[3].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta/4;
    coors0[3].latitude = self.mapView.region.center.latitude-0.001;
    /*添加矩形区域A左上角的A4点*/
    coors0[4].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta/4;
    coors0[4].latitude = self.mapView.region.center.latitude-0.001;
    /*再次添加矩形区域A左下角的A1点，构成一个闭环，此时A1点被添加两遍*/
    coors0[5].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta/4;
    coors0[5].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta/4;
    /*添加不规则区域B的起点B1点*/
    coors0[6].longitude = 116.28248 ;//海淀区
    coors0[6].latitude = 40.0096690;
    /*添加不规则区域B的起点B2点*/
    coors0[7].longitude = 116.272517;//丰台区
    coors0[7].latitude = 39.841958;
    /*添加不规则区域B的起点B3点*/
    coors0[8].longitude = 116.348606;//大兴区
    coors0[8].latitude = 39.732077;
    /*添加不规则区域B的起点B4点*/
    coors0[9].longitude = 116.531468;//朝阳区
    coors0[9].latitude = 39.957906;
    /*再次添加不规则区域B的起点B1点，此时B1点被添加两遍，如果是最后一个点，那么该区域的起点都将被添加三遍*/
    coors0[10].longitude = 116.28248 ;//海淀区
    coors0[10].latitude = 40.0096690;
    /*再次添加矩形区域A左下角的A1点，构成一个闭环，此时A1点被添加三遍，如果不是最后一个区域，那么区域的起点都将被添加三遍*/
    coors0[11].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta/4;
    coors0[11].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta/4;
    /*添加屏幕左下角的S1点，此时S1点被添加2遍*/
    coors0[12].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[12].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕右下角的S2点*/
    coors0[13].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors0[13].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕右上角的S3点*/
    coors0[14].longitude = self.mapView.region.center.longitude+self.mapView.region.span.longitudeDelta*1.5;
    coors0[14].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕左上角的S4点*/
    coors0[15].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[15].latitude = self.mapView.region.center.latitude+self.mapView.region.span.latitudeDelta*1.5;
    /*添加屏幕左下角的S1点，此时S1点被添加三遍，屏幕边界点也最多被添加三遍*/
    coors0[16].longitude = self.mapView.region.center.longitude-self.mapView.region.span.longitudeDelta*1.5;
    coors0[16].latitude = self.mapView.region.center.latitude-self.mapView.region.span.latitudeDelta*1.5;

    BMKPolygon *polygonModel0 = [BMKPolygon polygonWithCoordinates:coors0 count:17];
    [self.mapView addOverlay:polygonModel0];
    return;
    
#pragma mark 非程序实现-有雾霾
    /*
     //添加底部阴影
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

     //添加多边形区域
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
*/
}

@end
