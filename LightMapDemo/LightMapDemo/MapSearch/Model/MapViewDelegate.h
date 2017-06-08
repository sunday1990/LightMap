//
//  MapViewDelegate.h
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "MapViewTargetProtocol.h"
#import "MapSearchKeyModel.h"

typedef enum : NSUInteger {
    MapViewDelegateEventDidFinishLoading = 0,
    MapViewDelegateEventDidChangeRegion = 1,
    MapViewDelegateEventDidClickedMapBlank = 2,
    MapViewDelegateEventAnnotation = 3
    
}MapViewDelegateEvent;
typedef void(^ReloadDataBlock)(MapViewDelegateEvent delegateEvent);


@interface MapViewDelegate : NSObject<BMKMapViewDelegate>

@property (nonatomic,weak)MapSearchKeyModel *searchKeyModel;

@property (nonatomic,copy)ReloadDataBlock reloadBlock;

@property (nonatomic,assign)id<MapViewTargetProtocol>target;

@end
