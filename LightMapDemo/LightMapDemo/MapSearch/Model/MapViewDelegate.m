//
//  MapViewDelegate.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#import "MapViewDelegate.h"
#import "MapAnnotationView.h"
#import "MapBasePolygonView.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation MapViewDelegate

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

/****************点击地图空白区域的回调****************/
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    BOOL tapInPolygon = NO;
    if (mapView.overlays.count>0) {
        for (BMKPolygon *polygon in mapView.overlays) {
            if ([polygon isKindOfClass:[MapBasePolygon class]]) {
              //  MapBasePolygonView *polygonView = (MapBasePolygonView *)[mapView viewForOverlay:polygon];
                BMKMapPoint mapPoint = BMKMapPointForCoordinate(coordinate);
                CGMutablePathRef mpr = CGPathCreateMutable();
                BMKMapPoint *polygonPoints = polygon.points;
                for (int p=0; p < polygon.pointCount; p++){
                    BMKMapPoint mp = polygonPoints[p];
                    if (p == 0){
                        CGPathMoveToPoint(mpr, NULL, mp.x, mp.y);
                    }else{
                        CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
                    }
                }
                CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);
                tapInPolygon = CGPathContainsPoint(mpr, NULL, mapPointAsCGP, FALSE);
                CGPathRelease(mpr);
                if (tapInPolygon) {
                    [SVProgressHUD showSuccessWithStatus:@"polygon被点击"];
                }
            }
        }
    }
    if (self.reloadBlock) {
        self.reloadBlock(MapViewDelegateEventDidClickedMapBlank);
    }
}



/****************根据overlay生成对应的View****************/
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MapBasePolygon class]]) {
        MapBasePolygonView* polygonView = [[MapBasePolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0 blue:0.5 alpha:1];
        polygonView.fillColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.9];
        polygonView.lineWidth = 0.5;
        polygonView.lineDash = YES;
        return polygonView;
    }else if([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0 blue:0.5 alpha:1];
        polygonView.fillColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.6];
        polygonView.alpha = 0.7;
        polygonView.lineWidth = 0.5;
        polygonView.lineDash = YES;
        return polygonView;
    }else{
        return nil;
    }
}

@end

#pragma clang diagnostic pop
