//
//  MapAnimationDefines.h
//  SpaceHome
//
//  Created by ccSunday on 2017/5/23.
//
//Abstract:跟业务强相关，仅限地图使用。

#ifndef MapAnimationDefines_h
#define MapAnimationDefines_h

// 进入地图全屏模式
#define map_animationsToFullScreen(duration) \
    animateWithDuration:duration\
    animations:^{\
        self.mapInfoBar.right = 0;\
    }

// 退出地图全屏模式
#define map_animationsExitFullScreen(duration)\
    animateWithDuration:duration\
    animations:^{\
        self.mapInfoBar.centerX = WIDTH/2;\
    }

//动画结束请求数据
#define map_AnimationFinished\
    completion:^(BOOL finished) {\
        [self requestData];\
    }

#endif /* MapAnimationDefines_h */
