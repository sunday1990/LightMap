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

}

#pragma mark 开启地图的惯性缩放
- (void)openMapInertiaDragWithCoefficient:(float)inertiaCoefficient{
    /*惯性系数也就是方程的二次项系数*/
    _quadraticCoefficient = inertiaCoefficient;
    [self handleRelevantPrivateViewOfBaiduMap];
}

#pragma mark 处理百度地图的相关私有视图
- (void)handleRelevantPrivateViewOfBaiduMap{
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in _mapView.subviews) {
        if ([subView isKindOfClass:[mapViewClass class]]) {
            id TapDetectingView = NSClassFromString(@"TapDetectingView");
            for (UIView *subclassView in subView.subviews) {
                if ([subclassView isKindOfClass:[TapDetectingView class]]) {
                    [self hookMethodsInRelevantView:subclassView];
                }
            }
        }
    }
}

#pragma mark hook地图私有视图的相关方法
- (void)hookMethodsInRelevantView:(UIView *)mapTapDetectingView{
    WEAK(self);
    self.methodHookedBlock = ^(id<AspectInfo>hookedObject,...){
        STRONG(weakself);
        NSInvocation *invocation = [hookedObject originalInvocation];
        SEL hookedSelector = invocation.selector;
        if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleBeginTouchPoint"]) {    //双指运动触摸屏幕
            [strongSelf hookedMethod_handleDoubleBeginTouchPoint];
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleMoveTouchPoint"]) {//处理双指移动
            NSLog(@"双指移动中");
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleEndTouchPoint"]){  //双指移动停止
            [strongSelf hookedMethod_handleDoubleEndTouchPoint];
            
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleScale:"]){                //"handleScale: 手动改变地图的缩放等级的触发事件
            NSArray *args = [hookedObject arguments];
            [strongSelf hookedMethod_handleScale:args];
        }    };
    for (NSString * selString  in [mapTapDetectingView.class arrayOfInstanceMethods]) {
        [mapTapDetectingView aspect_hookSelector:NSSelectorFromString(selString) withOptions:AspectPositionAfter usingBlock:self.methodHookedBlock error:nil];
    }
}

#pragma mark 双指触摸屏幕
- (void)hookedMethod_handleDoubleBeginTouchPoint{
    NSLog(@"双指触摸屏幕");
    _zoomLevelPinStart = self.mapView.zoomLevel;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    _tPinStart =[dat timeIntervalSince1970];
}

#pragma mark 双指移动停止
- (void)hookedMethod_handleDoubleEndTouchPoint{
    NSLog(@"双指移动结束");
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    _tPinEnd =[dat timeIntervalSince1970];
    _zoomLevelPinEnd = self.mapView.zoomLevel;
    _tPinMoving = _tPinEnd - _tPinStart;
    /*0:如果用户双指停留时间时间大于0.8s，那么不做惯性运动。*/
    if (_tPinMoving > 0.8) {
        return;
    }
    /*1、根据两个点坐标(0,_zoomLevelPinStart)和(_tPinMoving,_zoomLevelPinEnd)和二次项系数可以得到对应的抛物线方程。也就是可以求得一次项系数与常数项的值*/
    [self parabola_calculateOneCoefficient];
    [self parabola_calculateConstantCoefficient];
    
    /*2、求出该抛物线的顶点，也就是速度为0的点，在顶点处，地图停止运动，计算该点的时间_tStirless，这个_tStirless就是双指离开后，地图的惯性运动时间。*/
    [self parabola_calculateStirlessTime];
    
    /*3、最后将上一步得到的惯性运动时长_tStirless减去手指移开时候的时间_tPinEnd，再将这个差值分成10份，根据抛物线方程依次计算对应时间的level值，调用mapView的setZoomLevel方法*/
    [self parabola_refreshMapZoomLevel];
}

#pragma mark handleScale
- (void)hookedMethod_handleScale:(NSArray *)args{
    if ([args[0] floatValue] > 0) {
        _quadraticCoefficient = -fabsf(_quadraticCoefficient);
    }else{
        _quadraticCoefficient = fabsf(_quadraticCoefficient);
    }
}


#pragma mark  /*计算抛物线的一次项系数*/
- (void)parabola_calculateOneCoefficient{
    _oneCoefficient = ((_zoomLevelPinEnd-_zoomLevelPinStart) - _quadraticCoefficient * (_tPinMoving * _tPinMoving))/(_tPinMoving);
}

#pragma mark  /*计算抛物线常数项的值*/
- (void)parabola_calculateConstantCoefficient{
    
    _constantCoefficient = _zoomLevelPinStart;

}

#pragma mark  /*计算抛物线速度为0（也就是静止）的时间*/
- (void)parabola_calculateStirlessTime{
    _tStirless = (-_oneCoefficient)/(2*_quadraticCoefficient);
}

#pragma mark  /*刷新抛物线上的y值：zoomlevel，在这里分成了10份*/
- (void)parabola_refreshMapZoomLevel{
    float unitZoomLevelDuringTime = (_tStirless - _tPinMoving)/MAP_ZOOM_NUMS;
    for (int i = 1; i<=MAP_ZOOM_NUMS; i++) {
        float tempZoomLevel = [self parabola_calculateMapZoomLevelAtRealTime:_tPinMoving+i*unitZoomLevelDuringTime];
        dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * (i*unitZoomLevelDuringTime)));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_mapView setZoomLevel:tempZoomLevel];
        });
    }
}
#pragma mark  /*实时计算抛物线上time所对应的maplevel*/
- (CGFloat)parabola_calculateMapZoomLevelAtRealTime:(float)realTime{
    return _quadraticCoefficient *(realTime *realTime) + _oneCoefficient * realTime + _zoomLevelPinStart;
}

#pragma mark /************************************************ 地图阻尼相关 **************************************************/

/**
 阻尼效果改变地图等级
 
 @param currentLevel  当前的等级
 @param settingLevel  要设定的等级
 */

- (void)dampZoomingMapLevelFromCurrentValue:(float)currentLevel
                             ToSettingValue:(float)settingLevel{
    float unitZoomLevelDuringTime = MAP_ZOOM_DURATION/MAP_ZOOM_NUMS;
    float unitZoomLevelIncrement = (settingLevel - currentLevel)/MAP_ZOOM_NUMS;
    for (int i = 1; i<=MAP_ZOOM_NUMS; i++) {
        float tempZoomLevel = currentLevel+i*unitZoomLevelIncrement;
        dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * (i*unitZoomLevelDuringTime)));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_mapView setZoomLevel:tempZoomLevel];
        });
    }
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
    
//    [self category_addAnnotations];
}

#pragma mark  隐藏百度地图的logo
- (void)hideBaiduMapLogo{
    [self setBaiduMapLogoHiddenStatus:YES];
}

#pragma mark  显示百度地图的logo
- (void)showBaiduMapLogo{
    [self setBaiduMapLogoHiddenStatus:NO];
}

- (void)setBaiduMapLogoHiddenStatus:(BOOL)status{
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in _mapView.subviews) {
        if ([subView isKindOfClass:[mapViewClass class]]) {
            for (UIView *subclassView in subView.subviews) {
                if ([subclassView isKindOfClass:[UIImageView class]]) {
                    if (subclassView.tag == 0) {
                        subclassView.hidden = status;
                        
                    }
                }
            }
        }
    }
}

- (void)dealloc{
    NSLog(@"dealloc mapviewManager");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MapViewShouldRemoveAllAnnotations object:nil];
}


@end
