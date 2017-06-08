//
//  MapBasePolygonView.m
//  SpaceHome
//
//  Created by ccSunday on 2017/6/7.
//
//

#import "MapBasePolygonView.h"
#import "AppDelegate.h"
@implementation MapBasePolygonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}
@end
