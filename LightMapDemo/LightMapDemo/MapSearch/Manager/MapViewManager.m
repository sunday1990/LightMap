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
}

#pragma mark 点击回到我当前所在的地理位置
-(void)backToGeographOfCurrent{
 //TODO
}

- (void)changeMapLevelWithTheClickCenter:(CLLocationCoordinate2D)centerCoordinate{
    [_mapView setCenterCoordinate:centerCoordinate];

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
    /*隐藏图标*/
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
