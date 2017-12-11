//
//  MapAdpater.m
//  SpaceHome
//
//  Created by ccSunday on 2017/11/27.
//  Copyright © 2017年 kongjianjia.com. All rights reserved.
//

#import "BMKMapViewAdpater.h"
#import <Aspects/Aspects.h>
#import "NSObject+RunTimeHelper.h"
/*地图缩放的时间*/
#define MAP_ZOOM_DURATIONS  0.6
/*地图从一个级别缩放至另一个级别，地图的缩放总次数*/
#define MAP_ZOOM_NUM      25.0

#define WEAK(object)                         __weak typeof(object) weak##object = object;
#define STRONG(object)                       __strong __typeof(object)strongSelf = object;

static int zoomDisplayCount;

static CADisplayLink *displayLink;

/*开始缩放的时间*/
static NSTimeInterval _tPinStart;
/*结束缩放，也就是手指移开的时间*/
static NSTimeInterval _tPinEnd;
/*记录双指在地图上的的捏合时长。                      _tPinMoving =  _tPinEnd - _tPinStart;*/
static NSTimeInterval _tPinMoving;
/*记录惯性运动停止，速度为0(也就是静止)时候的时间。      _tStirless-_tPinMoving可以得出手指离开后，惯性运动的时长，注意：需要对坐标系进行转换后，才可以这样计算*/
static NSTimeInterval _tStirless;


/*记录开始拖拽时候的地图等级*/
static float _zoomLevelPinStart;
/*记录结束拖拽时候的地图等级*/
static float _zoomLevelPinEnd;


/*惯性运动方程的二次项系数*/
static float _quadraticCoefficient;
/*惯性运动方程的一次项系数*/
static float _oneCoefficient;
/*惯性运动方程的常数项*/
static float _constantCoefficient;

static BMKMapView *_mapView;

static BOOL _close;

static BMKMapViewAdpater *_mapAdpater;

@implementation BMKMapViewAdpater

+ (void)initialize{
    _mapAdpater = [[BMKMapViewAdpater alloc]init];
}

+ (void)mapView:(BMKMapView *)mapView closeMapInertialDrag:(BOOL)close{
    _mapView = mapView;
    _close = close;
}

+ (void)mapView:(BMKMapView *)mapView openInertiaDragWithCoefficient:(float)inertiaCoefficient{
    _mapView = mapView;
    /*惯性系数也就是方程的二次项系数*/
    _quadraticCoefficient = inertiaCoefficient;
    [self handleRelevantPrivateViewOfBaiduMap:mapView];
}

+ (void)mapView:(BMKMapView *)mapView dampZoomingMapLevelFromCurrentValue:(float)currentLevel
 ToSettingValue:(float)settingLevel{
    float unitZoomLevelLastTime = MAP_ZOOM_DURATIONS/MAP_ZOOM_NUM;
    for (int i = 1; i<=MAP_ZOOM_NUM; i++) {
        float realTime = i * unitZoomLevelLastTime;
        /*方程y = aX^2 + bX + C */
        float a = (currentLevel - settingLevel)/(MAP_ZOOM_DURATIONS * MAP_ZOOM_DURATIONS);
        float b = (-2) * a * MAP_ZOOM_DURATIONS;
        float c = currentLevel;
        float tempZoomLevel = a * realTime * realTime + b * realTime + c;
        dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * (realTime)));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [mapView setZoomLevel:tempZoomLevel];
        });
    }
}

+ (void)mapView:(BMKMapView *)mapView setBaiduMapLogoHiddenStatus:(BOOL)status{
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in mapView.subviews) {
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

+ (void)handleRelevantPrivateViewOfBaiduMap:(BMKMapView *)mapview{
    id mapViewClass = NSClassFromString(@"MapView");
    for (UIView *subView in mapview.subviews) {
        if ([subView isKindOfClass:[mapViewClass class]]) {
            id TapDetectingView = NSClassFromString(@"TapDetectingView");
            for (UIView *subclassView in subView.subviews) {
                if ([subclassView isKindOfClass:[TapDetectingView class]]) {
                    [_mapAdpater hookMethodsInDetectingView:subclassView];
                }
            }
        }
    }
}

#pragma mark hook MapTapDetectingView的相关方法
- (void)hookMethodsInDetectingView:(UIView *)mapTapDetectingView{
    void (^MethodHookedBlock)(id<AspectInfo>) = ^(id<AspectInfo>hookedObject){
        if (_close == YES) {
            return;
        }
        NSInvocation *invocation = [hookedObject originalInvocation];
        SEL hookedSelector = invocation.selector;
        if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleBeginTouchPoint"]) {    //双指运动触摸屏幕
            [_mapAdpater hookedMethod_handleDoubleBeginTouchPoint];
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleMoveTouchPoint"]) {//处理双指移动
            //TODO:
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleDoubleEndTouchPoint"]){  //双指移动停止
            [_mapAdpater hookedMethod_handleDoubleEndTouchPoint];
            
        }else if ([NSStringFromSelector(hookedSelector) isEqualToString:@"aspects__handleScale:"]){                //"handleScale: 手动改变地图的缩放等级的触发事件
            NSArray *args = [hookedObject arguments];
            [_mapAdpater hookedMethod_handleScale:args];
        }
    };
    for (NSString * selString in [mapTapDetectingView.class arrayOfInstanceMethods]) {
        [mapTapDetectingView aspect_hookSelector:NSSelectorFromString(selString) withOptions:AspectPositionAfter usingBlock:MethodHookedBlock error:nil];
    }
}

#pragma mark 双指触摸屏幕
- (void)hookedMethod_handleDoubleBeginTouchPoint{
    if (displayLink) {
        displayLink.paused = YES;
        displayLink = nil;
        [displayLink invalidate];
        zoomDisplayCount = 0;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeMapLevelByStep) object:nil];
        NSLog(@"终止displaylink");
    }
    _zoomLevelPinStart = _mapView.zoomLevel;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    _tPinStart =[dat timeIntervalSince1970];
}

#pragma mark 双指移动停止
- (void)hookedMethod_handleDoubleEndTouchPoint{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    _tPinEnd =[dat timeIntervalSince1970];
    _zoomLevelPinEnd = _mapView.zoomLevel;
    _tPinMoving = _tPinEnd - _tPinStart;
    /*0:如果用户双指停留时间大于0.8s，那么不做惯性运动。*/
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

#pragma mark handleScale:
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

#pragma mark /*计算抛物线速度为0（也就是静止）的时间*/
- (void)parabola_calculateStirlessTime{
    _tStirless = (-_oneCoefficient)/(2*_quadraticCoefficient);
}

#pragma mark /*刷新抛物线上的y值：zoomlevel，在这里使之与屏幕刷新频率一致/
- (void)parabola_refreshMapZoomLevel{
    NSTimeInterval zoomLevelDuringTime = _tStirless - _tPinMoving;//总得惯性运动时间
    [self startAnimateWithtimeDuration:zoomLevelDuringTime];
}

#pragma mark /*实时计算抛物线上time所对应的maplevel*/
- (CGFloat)parabola_calculateMapZoomLevelAtRealTime:(float)realTime{
    return _quadraticCoefficient *(realTime *realTime) + _oneCoefficient * realTime + _zoomLevelPinStart;
}

- (void)startAnimateWithtimeDuration:(NSTimeInterval)time{
    if (time > 0) {
        if (displayLink) {
            displayLink.paused = YES;
        }
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeMapLevelByStep)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        displayLink.paused = NO;
        dispatch_time_t timeT =  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * time));
        dispatch_after(timeT, dispatch_get_main_queue(), ^{
            displayLink.paused = YES;
            [displayLink invalidate];
            displayLink = nil;
            zoomDisplayCount = 0;
        });
    }
}

- (void)changeMapLevelByStep{
    zoomDisplayCount ++;
    float time = zoomDisplayCount/60.f;
    float tempZoomLevel = [self parabola_calculateMapZoomLevelAtRealTime:_tPinMoving + time];
    [_mapView setZoomLevel:tempZoomLevel];
}
@end
