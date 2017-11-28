# LightMap
轻量级的地图解决方案,可以的话，请star一下，这将使我知道这东西还是有些用的。
关于惯性缩放部分，已经将运动逻辑从原来的代码中抽离到BMKMapViewAdapter中了，这个类专门处理我们自定义的运动特性。使用时可以将这个类和他的依赖类挪到自己的项目中。

相关方法:
```
/**
 开启惯性缩放
 @param mapView mapView description
 @param inertiaCoefficient 惯性系数
 */
+ (void)mapView:(BMKMapView *)mapView openInertiaDragWithCoefficient:(float)inertiaCoefficient;

/**

 关闭惯性缩放
 @param mapView mapView description
 @param close 关闭，传YES即可
 */
+ (void)mapView:(BMKMapView *)mapView closeMapInertialDrag:(BOOL)close;


/**
阻尼运动

 @param mapView mapView description
 @param currentLevel 当前级别
 @param settingLevel 要设置的级别
 */
+ (void)mapView:(BMKMapView *)mapView dampZoomingMapLevelFromCurrentValue:(float)currentLevel ToSettingValue:(float)settingLevel;


```
