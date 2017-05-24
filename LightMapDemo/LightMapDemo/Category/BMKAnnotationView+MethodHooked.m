//
//  BMKAnnotationView+MethodHooked.m
//  SpaceHome
//
//  Created by ccSunday on 2017/5/24.
//
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#import "BMKAnnotationView+MethodHooked.h"
#import "NSObject+RunTimeHelper.h"

@implementation BMKAnnotationView (MethodHooked)
+ (void)load{
    
    [BMKActionPaopaoView ml_swizzleInstanceMethodSEL:@selector(setPaopaoView:) withSEL:@selector(sh_setPaopaoView:)];
    [BMKActionPaopaoView ml_swizzleInstanceMethodSEL:@selector(handleSingleTap) withSEL:@selector(sh_handleSingleTap)];
}

- (void)sh_handleSingleTap{
    NSLog(@"success hook BMKAnnotationView Method");
    
}

- (void)sh_setPaopaoView:(BMKActionPaopaoView *)paopaoView{

    NSLog(@"success hook setPaopaoVie Method");

}

@end

#pragma clang diagnostic pop
