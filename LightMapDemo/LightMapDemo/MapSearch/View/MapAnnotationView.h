//
//  MaptAnnotatiionView.h
//  LightMapDemo
//
//  Created by ccSunday on 2017/5/24.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MapAnnotationView : BMKAnnotationView
-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

@end
