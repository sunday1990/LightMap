//
//  MapSearchKeyModel.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MapSearchKeyModel : NSObject
/****************************************必传字段**************************************************/
/**
 类型
 */
@property (nonatomic,copy)NSString *typeID;
/**
 要获取的数据级别
 */
@property (nonatomic,copy)NSString *level;
/**
 视野范围左下方经度坐标
 */
@property (nonatomic,copy)NSString *zxlng ;
/**
 视野范围左下方纬度坐标
 */
@property (nonatomic,copy)NSString *zxlat;
/**
 视野范围右上方经度坐标
 */
@property (nonatomic,copy)NSString *yslng;
/**
 视野范围右上方纬度坐标
 */
@property (nonatomic,copy)NSString *yslat;

/****************************************非必传字段**************************************************/
/**
 价格最小值(不限：-1)
 */
@property (nonatomic,copy)NSString *price_min;
/**
 价格最大值(不限：-1)
 */
@property (nonatomic,copy)NSString *price_max;
/**
 面积最小值(不限：-1)
 */
@property (nonatomic,copy)NSString *area_min;
/**
 面积最大值(不限：-1)
 */
@property (nonatomic,copy)NSString *area_max;
/**********************本地使用的字段，不上传服务器，注意所有的本地字段需要写到.m的filterArray中***********************************/
/**
 存放最终要上传到服务器的所有字段
 */
@property (nonatomic,strong)NSMutableDictionary *uploadParam;
/**
 经纬度区域范围
 */
@property (nonatomic,assign)BMKCoordinateRegion coordinateRange;

/**
 结果数组
 */
@property (nonatomic,strong)NSMutableArray *resultArray;
/**
 获取最终要上传到服务器的字典
 
 @return return value description
 */
- (NSDictionary *)searchKeyModel_getRequestParams;
@end
