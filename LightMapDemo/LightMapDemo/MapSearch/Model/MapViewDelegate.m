//
//  MapViewDelegate.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewDelegate.h"
#import "MapAnnotationView.h"
@implementation MapViewDelegate
/****************地图首次加载完的时候调用****************/

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    
    //block回调，重新请求数据
    BMKCoordinateRegion mreg = mapView.region;
    
    self.searchKeyModel.coordinateRange = mreg;
    
    if (self.reloadBlock) {
        
        self.reloadBlock(MapViewDelegateEventDidFinishLoading);
        
    }
}
/****************地图区域改变后的回调，滑动地图与缩放地图最后都会调用该方法*****************/
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChangeAnimated");
    [self operationWithMapView:mapView delegateEvent:MapViewDelegateEventDidChangeRegion];
}
//
/****************添加标注****************/
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    MapAnnotationView *annotationView = [[MapAnnotationView alloc]initWithFrame:CGRectMake(0, 0, 60, 20) target:self.target action:@selector(annotationDidClicked)];
    annotationView.annotation = annotation;
    return annotationView;
}


- (void)operationWithMapView:(BMKMapView *)mapView delegateEvent:(MapViewDelegateEvent)event{
    
    BMKCoordinateRegion mreg = mapView.region;
    self.searchKeyModel.coordinateRange = mreg;
    
    if (self.reloadBlock) {
        
        self.reloadBlock(event);
    }
}

@end
