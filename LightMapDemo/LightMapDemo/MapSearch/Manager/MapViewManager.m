//
//  MapViewManager.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager.h"
#import <math.h>
#import "MapViewManager+Annotations.h"
#import "Constant_Basic.h"
#import "MyControl.h"
#import "MapNetWorkManager.h"
#import "NSObject+RunTimeHelper.h"
#import "TestPolygonModel.h"

#import "BMKMapViewAdpater.h"

/*定义地图缩放的持续时长*/
#define MAP_ZOOM_DURATION  1.0
/*地图从一个级别缩放至另一个级别，地图的缩放总次数*/
#define MAP_ZOOM_NUMS      10.0

NSString * const MapViewDidChangeDesType = @"com.lightMapDemo.mapViewManager.desTypeDidChanged";

@interface MapViewManager()
{
/*以下全局变量全部跟地图惯性运动相关*/
    /*开始缩放的时间*/
    NSTimeInterval _tPinStart;
    /*结束缩放，也就是手指移开的时间*/
    NSTimeInterval _tPinEnd;
    /*记录双指在地图上的的捏合时长。                      _tPinMoving =  _tPinStart - _tPinStart;*/
    NSTimeInterval _tPinMoving;
    /*记录惯性运动停止，速度为0(也就是静止)时候的时间。      _tStirless-_tPinMoving可以得出手指离开后，惯性运动的时长*/
    NSTimeInterval _tStirless;
    
    
    
    /*记录开始拖拽时候的地图等级*/
    float _zoomLevelPinStart;
    /*记录结束拖拽时候的地图等级*/
    float _zoomLevelPinEnd;
    
    
    
    /*惯性运动方程的二次项系数*/
    float _quadraticCoefficient;
    /*惯性运动方程的一次项系数*/
    float _oneCoefficient;
    /*惯性运动方程的常数项*/
    float _constantCoefficient;
}

@end

@implementation MapViewManager

singletonImplementation(MapViewManager)

- (id)init{
    if (self = [super init]) {
        //注册通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAllAnnotations) name:MapViewShouldRemoveAllAnnotations object:nil];
        [self initializeMapView];
        [self initializeCurrentlocBtn];
    }
    return self;
}

#pragma mark /************************************************ 各种初始化 **************************************************/

/**
 初始化mapView和其上的subview
 */
- (void)initializeMapView{
    //初始化mapView
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _mapView.zoomLevel = 12;
    _mapView.minZoomLevel = 11;
    _mapView.maxZoomLevel = 20;
    //初始化位置信息
    [self backToGeographOfCurrent];
}

/**
 初始化回到初始位置按钮
 */
- (void)initializeCurrentlocBtn{
    self.currentLocBtn=[MyControl createButtonWithFrame:CGRectMake(12,HEIGHT-12-30, 30, 30) ImageName:@"mapPagepositioning" Target:self Action:@selector(backToGeographOfCurrent) Title:nil];
    [_mapView addSubview:self.currentLocBtn];
   
    UIButton *btnZoomOut = [MyControl createButtonWithFrame:CGRectMake(12,HEIGHT-UI_TAB_BAR_HEIGHT-12-72, 30, 30) ImageName:@"mapPageZoomIn" Target:self Action:@selector(btnZoomClicked:) Title:nil];
    btnZoomOut.tag = 100;
    [_mapView addSubview:btnZoomOut];
  
    UIButton *btnZoomIn = [MyControl createButtonWithFrame:CGRectMake(12,HEIGHT-UI_TAB_BAR_HEIGHT-12-102, 30, 30) ImageName:@"mapPageZoomOut" Target:self Action:@selector(btnZoomClicked:) Title:nil];
    btnZoomIn.tag = 200;
    [_mapView addSubview:btnZoomIn];
}

#pragma mark /************************************************ 地图惯性相关 **************************************************/

#pragma mark 关闭地图惯性缩放
- (void)cloaseMapInertialDrag{
//codes: ...
    [BMKMapViewAdpater mapView:self.mapView closeMapInertialDrag:YES];
}

#pragma mark 开启地图的惯性缩放
- (void)openMapInertiaDragWithCoefficient:(float)inertiaCoefficient{
    /*惯性系数也就是方程的二次项系数*/
    [BMKMapViewAdpater mapView:self.mapView openInertiaDragWithCoefficient:inertiaCoefficient];
}


#pragma mark /************************************************ 地图阻尼相关 **************************************************/

/**
 阻尼效果改变地图等级
 
 @param currentLevel  当前的等级
 @param settingLevel  要设定的等级
 */

- (void)dampZoomingMapLevelFromCurrentValue:(float)currentLevel
                             ToSettingValue:(float)settingLevel{
    [BMKMapViewAdpater mapView:self.mapView dampZoomingMapLevelFromCurrentValue:currentLevel ToSettingValue:settingLevel];
}
#pragma mark /************************************************ Event Responses **************************************************/
#pragma mark 加减号点击事件
-(void)btnZoomClicked:(UIButton*)btn
{
    if( btn.tag == 100 ){
        [self dampZoomingMapLevelFromCurrentValue:self.mapView.zoomLevel ToSettingValue:self.mapView.zoomLevel-1];
    }else{
        [self dampZoomingMapLevelFromCurrentValue:self.mapView.zoomLevel ToSettingValue:self.mapView.zoomLevel+1];
    }
}

#pragma mark /************************************************ 标注和logo **************************************************/

#pragma mark 点击回到我当前所在的地理位置
-(void)backToGeographOfCurrent{
    //TODO：
}

/**
 移除标注
 */
- (void)removeAllAnnotations{
    [self category_removeAllAnnotations];
}

/**
 添加标注
 */
- (void)addAnnotations{
    
    [self category_addAnnotations];
}

#pragma mark  隐藏百度地图的logo
- (void)hideBaiduMapLogo{
    [BMKMapViewAdpater mapView:self.mapView setBaiduMapLogoHiddenStatus:YES];
}

#pragma mark  显示百度地图的logo
- (void)showBaiduMapLogo{
    [BMKMapViewAdpater mapView:self.mapView setBaiduMapLogoHiddenStatus:NO];
}

- (void)dealloc{
    NSLog(@"dealloc mapviewManager");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MapViewShouldRemoveAllAnnotations object:nil];
}

- (NSMutableArray *)locationArray{
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LocationCoordinate" ofType:@"plist"];
        //字典数组
        NSArray *dicArray = [NSArray arrayWithContentsOfFile:filePath];
        //字典数组转化为模型数组
        NSArray *allArray = [TestPolygonModel mj_objectArrayWithKeyValuesArray:dicArray];
        
        NSMutableArray *array0 = [NSMutableArray array];
        for (int i = 1; i<4; i++) {
            [array0 addObject:allArray[i]];
        }
        [_locationArray addObject:array0];

        NSMutableArray *array1 = [NSMutableArray array];
        for (int i = 5; i<8; i++) {
            [array1 addObject:allArray[i]];
        }
        [_locationArray addObject:array1];
    }
    
    return _locationArray;
}


@end
