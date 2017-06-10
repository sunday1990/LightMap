//
//  MapViewController.m
//  LightMap
//
//  Created by ccSunday on 2017/5/23.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "MapViewController.h"
#import "Constant_Basic.h"
#import "UIView+frame.h"
#import "MapNetWorkManager.h"
#import "MapViewManager.h"
#import "MapSearchKeyModel.h"
#import "MapViewDelegate.h"
#import "MapInfomationBar.h"
#import "MapAnimationDefines.h"

@interface MapViewController ()<MapViewTargetProtocol>
/**
 操作mapview
 */
@property (nonatomic,strong)MapViewManager *mapViewManager;

/**
 搜索的key
 */
@property (nonatomic,strong)MapSearchKeyModel *searchKeyModel;

/**
 mapView的代理
 */
@property (nonatomic,strong)MapViewDelegate *mapViewDelegate;

/**
 view
 */
@property (nonatomic,strong)MapInfomationBar *mapInfoBar;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.mapViewManager.mapView];
//    [self.view addSubview:self.mapInfoBar];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.mapViewManager.mapView.delegate = self.mapViewDelegate;    // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapViewManager.mapView.delegate = nil;                     //不使用时将delegate设置为 nil
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark NetWork
- (void)requestData{
    //1、请求地图数据
    WEAK(_mapViewManager);
  
    [MapNetWorkManager managerRequestMapDetailWithModel:self.searchKeyModel Success:^{
        //2、添加标注模型
        [weak_mapViewManager addAnnotations];
        
    } Failure:^(NSError *error) {

    }];
}

#pragma mark  MapViewTargetProtocol
- (void)annotationDidClicked{
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIView map_animationsExitFullScreen(0.5)];
    }];
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"标注被点击" message:@"进入全屏模式" preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:action];
    [self presentViewController:alertVc animated:YES completion:nil];
    [UIView map_animationsToFullScreen(0.5)];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark GetProperty
- (MapViewManager *)mapViewManager{
    _mapViewManager = [MapViewManager sharedMapViewManager];
    _mapViewManager.searchKeyModel = self.searchKeyModel;
    [_mapViewManager hideBaiduMapLogo];
    return _mapViewManager;
}

- (MapSearchKeyModel *)searchKeyModel{
    if (!_searchKeyModel) {
        _searchKeyModel = [[MapSearchKeyModel alloc]init];
    }
    return _searchKeyModel;
}

- (MapViewDelegate *)mapViewDelegate{
    if (!_mapViewDelegate) {
        _mapViewDelegate = [[MapViewDelegate alloc]init];
        _mapViewDelegate.target = self;
        _mapViewDelegate.searchKeyModel = self.searchKeyModel;
        WEAK(self);
        _mapViewDelegate.reloadBlock = ^(MapViewDelegateEvent event){//block回调,重新请求数据，刷新地图
            if (event == MapViewDelegateEventDidFinishLoading) {
               //:TODO
                [weakself requestData];
            }else if (event == MapViewDelegateEventDidChangeRegion){
                [weakself requestData];
            }else if (event == MapViewDelegateEventDidFinishLoading){
               
            }else if(event == MapViewDelegateEventDidClickedMapBlank){
                [weakself requestData];
            }
        };
    }
    return _mapViewDelegate;
}

- (MapInfomationBar *)mapInfoBar{
    if (!_mapInfoBar) {
        _mapInfoBar = [[MapInfomationBar alloc]initWithFrame:CGRectMake(PADDING*3, UI_NAV_BAR_HEIGHT, WIDTH-PADDING*6, 35)];
        _mapInfoBar.searchKeyModel = self.searchKeyModel;
    }
    return _mapInfoBar;
}

- (void)dealloc{
    NSLog(@"dealloc mapViewController");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MapViewDidChangeDesType object:nil];
    self.mapViewManager.mapView = nil;
}
@end
