//
//  MaptAnnotatiionView.m
//  LightMapDemo
//
//  Created by ccSunday on 2017/5/24.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapAnnotationView.h"
#import "Constant_Basic.h"
#import "MyControl.h"
#import "UIView+frame.h"
@implementation MapAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = GetColor(clearColor);
        UIButton *btn = [MyControl createButtonWithFrame:self.bounds ImageName:nil Target:target Action:action Title:@"item"];
        btn.layer.cornerRadius = btn.height/2;
        btn.titleLabel.font = GetFont(10);
        btn.backgroundColor = GetColor(greenColor);
        [self addSubview:btn];
        
    }
    return self;
}

@end
