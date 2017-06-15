//
//  MapViewManager.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager.h"
#import "MapViewManager+Annotations.h"
#import "Constant_Basic.h"
#import "MyControl.h"
#import "MapNetWorkManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <math.h>
#import "NSObject+RunTimeHelper.h"
/*定义地图缩放的持续时长*/
#define MAP_ZOOM_DURATION  1.0
/*地图从一个级别缩放至另一个级别，地图的缩放总次数*/
#define MAP_ZOOM_NUMS      10.0

NSString * const MapViewDidChangeDesType = @"com.lightMapDemo.mapViewManager.desTypeDidChanged";

@interface MapViewManager()
{
/*以下全局变量全部跟地图惯性运动相关*/
    
    //记录两个时间tStart与tEnd
    NSTimeInterval _tStart;
    NSTimeInterval _tEnd;
    //记录双指在地图上的的捏合时间。                   _tPinMoving =  _tEnd - _tStart;
    NSTimeInterval _tPinMoving;
    //惯性运动停止，速度为0(也就是静止)时候的时间。      _tStirless-_tPinMoving可以得出手指离开后，惯性运动的时长
    NSTimeInterval _tStirless;
    
    
    //记录zoomLevelStart
    float _zoomLevelStart;
    //记录zoomLevelEnd
    float _zoomLevelEnd;
    //惯性运动停止，速度为0(也就是静止)时候的zoomLevel
    float _zoomLevelStirless;
    
    
    //惯性运动方程的二次项系数
    int     _quadraticCoefficient;
    //惯性运动方程的一次项系数
    CGFloat _oneCoefficient;
    //惯性运动方程的常数项
    CGFloat _constantCoefficient;
}

@property (nonatomic,weak)UIView *mapTapDetectingView;

@property (nonatomic,strong)NSMutableArray *scaleArray;

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

#pragma mark 关闭地图惯性缩放
- (void)cloaseMapInertialDrag{


}

#pragma mark 开启地图的惯性缩放
- (void)openMapInertiaDragWithCoefficient:(CGFloat)inertiaCoefficient{
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
                    self.mapTapDetectingView = subclassView;
                    [self hookRelevantMapMethods];
                }
            }
        }
    }
}

#pragma mark hook地图私有视图的相关方法
- (void)hookRelevantMapMethods{
    WEAK(self);
    self.methodHookedBlock = ^(id<AspectInfo>hookedObject,...){
        NSInvocation *invocation = [hookedObject originalInvocation];
        SEL hookedSelector = invocation.selector;
        if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleBeginTouchPoint"]) {    //双指运动触摸屏幕
            //TODO:
            NSLog(@"双指触摸屏幕");
            _zoomLevelStart = weakself.mapView.zoomLevel;
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            _tStart =[dat timeIntervalSince1970];
            [weakself.scaleArray removeAllObjects];
            
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleMoveTouchPoint"]) {//处理双指移动
            //TODO:
            NSLog(@"双指移动中");
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleEndTouchPoint"]){  //双指移动停止
            //TODO:在这个方法里添加惯性效果。
            NSLog(@"双指移动结束");
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            _tEnd =[dat timeIntervalSince1970];
            _zoomLevelEnd = weakself.mapView.zoomLevel;
            /*
             计算方程
             求出斜率为0的时间点，并计算双指离开后还要继续运动的时间tContinue，和此时对应的mapZoom
             将tContunue等分成10分。得到对应抛物线上的mapLevel。然后进行设置，模拟
             */
            [weakself parabola_calculateOneCoefficient];
            [weakself parabola_calculateConstantCoefficient];
            [weakself parabola_calculateStirlessTime];
            [weakself parabola_refreshMapZoomLevel];
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleScale:"]){//"handleScale: 手动改变地图的缩放等级的触发事件
            @autoreleasepool {
                NSArray *args = [hookedObject arguments];
                if ([args[0] floatValue] > 0) {
                    _quadraticCoefficient = -abs(_quadraticCoefficient);
                }else{
                    _quadraticCoefficient = abs(_quadraticCoefficient);
                }
                [weakself.scaleArray addObject:args[0]];
            }
    
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleMoveTouchPoint"]){
            NSLog(@"handleMoveTouchPoint");
        }
    };
    for (NSString * selString  in [self.mapTapDetectingView.class arrayOfInstanceMethods]) {
        [self.mapTapDetectingView aspect_hookSelector:NSSelectorFromString(selString) withOptions:AspectPositionAfter usingBlock:self.methodHookedBlock error:nil];
    }
}

/*计算抛物线的一次项系数*/
- (void)parabola_calculateOneCoefficient{
    _tPinMoving = _tEnd - _tStart;
    _oneCoefficient = ((_zoomLevelEnd-_zoomLevelStart) - _quadraticCoefficient * (_tPinMoving * _tPinMoving))/(_tPinMoving);
}

/*计算抛物线的常数项*/
- (void)parabola_calculateConstantCoefficient{
    
    _constantCoefficient = _zoomLevelStart;

}
/*计算抛物线速度为0（也就是静止）的时间*/
- (void)parabola_calculateStirlessTime{
    _tStirless = (-_oneCoefficient)/(2*_quadraticCoefficient);
    NSLog(@"_tStirless=%f",_tStirless - _tPinMoving);
}
/*刷新抛物线上的y值：zoomlevel，在这里分成了10份*/
- (void)parabola_refreshMapZoomLevel{
    float unitZoomLevelDuringTime = (_tStirless - _tPinMoving)/MAP_ZOOM_NUMS;
    for (int i = 1; i<=MAP_ZOOM_NUMS; i++) {
        float tempZoomLevel = [self parabola_calculateMapZoomLevelAtTime:_tPinMoving+i*unitZoomLevelDuringTime];
        dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * (i*unitZoomLevelDuringTime)));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_mapView setZoomLevel:tempZoomLevel];
        });
    }
}
/*实时计算抛物线上对应time的maplevel*/
- (CGFloat)parabola_calculateMapZoomLevelAtTime:(float)tempTime{
    return _quadraticCoefficient *(tempTime *tempTime) + _oneCoefficient * tempTime + _zoomLevelStart;
}

#pragma mark 加减号点击事件
-(void)btnZoomClicked:(UIButton*)btn
{
    if( btn.tag == 100 ){
        [self dampZoomingMapLevelFromCurrentValue:self.mapView.zoomLevel ToSettingValue:self.mapView.zoomLevel-1];
    }else{
        [self dampZoomingMapLevelFromCurrentValue:self.mapView.zoomLevel ToSettingValue:self.mapView.zoomLevel+1];
    }
}

#pragma mark 点击回到我当前所在的地理位置
-(void)backToGeographOfCurrent{
    //TODO：
}

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

/**
 隐藏百度地图的logo
 */
- (void)hideBaiduMapLogo{
    /*隐藏图标*/
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in _mapView.subviews) {
        if ([subView isKindOfClass:[mapViewClass class]]) {
            for (UIView *subclassView in subView.subviews) {
                if ([subclassView isKindOfClass:[UIImageView class]]) {
                    if (subclassView.tag == 0) {
                        subclassView.hidden = YES;
                        
                    }
                }
                
            }
            
        }
    }
}

/**
 显示百度地图的logo
 */
- (void)showBaiduMapLogo{
    /*显示图标*/
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in _mapView.subviews) {
        if ([subView isKindOfClass:[mapViewClass class]]) {
            for (UIView *subclassView in subView.subviews) {
                if ([subclassView isKindOfClass:[UIImageView class]]) {
                    if (subclassView.tag == 0) {
                        subclassView.hidden = NO;
                        
                    }
                }
                
            }
            
        }
    }
}

- (NSMutableArray *)scaleArray{
    if (!_scaleArray) {
        _scaleArray = [NSMutableArray array];
    }
    return _scaleArray;
}


- (void)dealloc{
    NSLog(@"dealloc mapviewManager");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MapViewShouldRemoveAllAnnotations object:nil];
}


@end
