//
//  GoelocationModule.h
//  RCTBaiduMap
//
//  Created by lovebing on 2016/10/28.
//  Copyright © 2016年 lovebing.org. All rights reserved.
//

#ifndef YYTraceModule_h
#define YYTraceModule_h

#import "BaseModule.h"
#import "RCTBaiduMapViewManager.h"

@interface YYTraceModule : BaseModule <BTKTraceDelegate,BTKTrackDelegate> {
}

/**
 标志是否已经开启轨迹服务
 */
@property (nonatomic, assign) BOOL isServiceStarted;

/**
 标志是否已经开始采集
 */
@property (nonatomic, assign) BOOL isGatherStarted;

@end

#endif /* YYTrackModule_h */
