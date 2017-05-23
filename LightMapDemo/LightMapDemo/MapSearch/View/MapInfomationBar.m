//
//  MapInfomationBar.m
//  SpaceHome
//
//  Created by ccSunday on 2017/5/21.
//
//

#import "MapInfomationBar.h"
#import "Constant_Basic.h"
#import "UIView+frame.h"
#import "MyControl.h"
@interface MapInfomationBar()

@property (nonatomic,strong)UIImageView *mapAveragePriceImgView;

@property (nonatomic,strong)UILabel     *mapAveragePriceLabel;

@property (nonatomic,strong)UILabel     *mapSpaceNumLabel;

@end

@implementation MapInfomationBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = self.height/2;
        [self initialize];
    }
    return self;
}

- (void)initialize{

    [self addSubview:self.mapAveragePriceImgView];
    [self addSubview:self.mapSpaceNumLabel];
    [self addSubview:self.mapAveragePriceLabel];
}

- (UILabel *)mapAveragePriceLabel{
    if (!_mapAveragePriceLabel) {
        _mapAveragePriceLabel = [[UILabel alloc] init];
        _mapAveragePriceLabel.font = [UIFont systemFontOfSize:13];
        _mapAveragePriceLabel.text = @"均价5元/天";
        _mapAveragePriceLabel.backgroundColor = [UIColor clearColor];
        _mapAveragePriceLabel.frame = CGRectMake(self.mapAveragePriceImgView.right+5, 0, self.width/2-35, self.mapSpaceNumLabel.height);
        _mapAveragePriceLabel.textColor = [UIColor whiteColor];

    }
    return _mapAveragePriceLabel;
}

- (UILabel *)mapSpaceNumLabel{
    if (!_mapSpaceNumLabel) {
        _mapSpaceNumLabel  = [[UILabel alloc]initWithFrame:CGRectMake(self.width/2+12,0, self.width/2-12*2,35)];
        _mapSpaceNumLabel.text = @"找到100个空间";
        _mapSpaceNumLabel.font = GetFont(13);
        _mapSpaceNumLabel.textColor = [UIColor whiteColor];
        _mapSpaceNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mapSpaceNumLabel;
}

- (UIImageView *)mapAveragePriceImgView{
    if (!_mapAveragePriceImgView) {
            _mapAveragePriceImgView = [MyControl createImageViewWithFrame:CGRectMake(5, 5, 25, 25) ImageName:@"map_rent_icon"];
    }
    return _mapAveragePriceImgView;
}

- (void)update{
    //从searchKeyModel中取出对应数据刷新

}

@end
