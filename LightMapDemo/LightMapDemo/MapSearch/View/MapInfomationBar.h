//
//  MapInfomationBar.h
//  SpaceHome
//
//  Created by ccSunday on 2017/5/21.
//
//

#import <UIKit/UIKit.h>

#import "MapSearchKeyModel.h"

@interface MapInfomationBar : UIView

@property (nonatomic,weak)MapSearchKeyModel *searchKeyModel;

- (void)update;

@end
//@interface MVPaopaoView : UIView

//-(void)initWithJJR:(CGRect)frame target:(id)target;
//-(void)updateWithJJR:(NSObject*)model;

