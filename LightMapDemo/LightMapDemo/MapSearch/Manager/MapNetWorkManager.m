//
//  MapNetWorkManager.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapNetWorkManager.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
NSString * const MapViewShouldRemoveAllAnnotations = @"com.lightMapDemo.mapNetWork.shouldRemoveAllAnnotations";

@implementation MapNetWorkManager

+ (void)managerRequestMapDetailWithModel:(MapSearchKeyModel *)searchKeyModel Success:(void(^)())successCallBack Failure:(void(^)(NSError *error))failureCallBack{
    //生成本地测试数据
    [[NSNotificationCenter defaultCenter]postNotificationName:MapViewShouldRemoveAllAnnotations object:nil];
    [searchKeyModel.resultArray removeAllObjects];
    BMKPointAnnotation *annotation1 = [[BMKPointAnnotation alloc]init];
    annotation1.coordinate = CLLocationCoordinate2DMake(39.92362200000000000, 116.41934400000000000);
    
    BMKPointAnnotation *annotation2 = [[BMKPointAnnotation alloc]init];
    annotation2.coordinate = CLLocationCoordinate2DMake(39.84195800000000000, 116.27251700000000000);
    
    [searchKeyModel.resultArray addObject:annotation1];
    [searchKeyModel.resultArray addObject:annotation2];
    
    //调用成功的回调
    if (successCallBack) {
        successCallBack();
    }
    return;
    NSDictionary *param = [searchKeyModel searchKeyModel_getRequestParams];
    NSString *url = @"www.baidu.com";
    //发起网络请求 Do Your NetWork 
}

@end
