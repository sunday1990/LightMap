//
//  MapViewManager.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewManager.h"
#import "MapViewManager+Annotations.h"
#import "MyControl.h"
#import "MapNetWorkManager.h"
/*定义地图缩放的持续时长*/
#define MAP_ZOOM_DURATION  1.0
/*地图从一个级别缩放至另一个级别，地图的缩放总次数*/
#define MAP_ZOOM_NUMS      10.0

NSString * const MapViewDidChangeDesType = @"com.lightMapDemo.mapViewManager.desTypeDidChanged";

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
 //TODO
}

- (void)changeMapLevelWithTheClickCenter:(CLLocationCoordinate2D)centerCoordinate{
    [_mapView setCenterCoordinate:centerCoordinate];

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
    [self category_addAnnotations];
    
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

- (void)dealloc{
    NSLog(@"dealloc mapviewManager");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MapViewShouldRemoveAllAnnotations object:nil];
}


@end
