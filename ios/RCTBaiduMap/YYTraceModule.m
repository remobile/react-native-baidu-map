//
//  GoelocationModule.m
//  RCTBaiduMap
//
//  Created by lovebing on 2016/10/28.
//  Copyright © 2016年 lovebing.org. All rights reserved.
//

#import "YYTraceModule.h"
#define GLOBAL_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation YYTraceModule {
    BMKPointAnnotation* _annotation;
}

@synthesize bridge = _bridge;


RCT_EXPORT_MODULE(BaiduYYTraceModule);

#pragma mark private function
RCT_EXPORT_METHOD(startService:(NSString *)entityName) {
    dispatch_async(GLOBAL_QUEUE, ^{
        BTKStartServiceOption *startServiceOption = [[BTKStartServiceOption alloc] initWithEntityName:entityName];
        [[BTKAction sharedInstance] startService:startServiceOption delegate:self];
    });
}

RCT_EXPORT_METHOD(stopService) {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopService:self];
    });
}

RCT_EXPORT_METHOD(startGather) {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] startGather:self];
    });
}
                  
RCT_EXPORT_METHOD(stopGather) {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopGather:self];
    });
}

RCT_EXPORT_METHOD(queryHistoryTrack:(NSString *)entityName serviceID:(NSUInteger)serviceID) {
    dispatch_async(GLOBAL_QUEUE, ^{
        // 构造请求对象
        NSUInteger endTime = [[NSDate date] timeIntervalSince1970];
        BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:entityName startTime:endTime - 84400 endTime:endTime isProcessed:TRUE processOption:nil supplementMode:BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_DESC pageIndex:1 pageSize:1000 serviceID:serviceID tag:1];
        // 发起查询请求
        [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];
    });
}

RCT_EXPORT_METHOD(queryLatestPoint:(NSString *)entityName serviceID:(NSUInteger)serviceID denoise:(BOOL)denoise mapMatch:(BOOL)mapMatch) {
    dispatch_async(GLOBAL_QUEUE, ^{
        // 设置纠偏选项
        BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
        option.denoise = denoise;
        option.mapMatch = mapMatch;
        option.radiusThreshold = 10;
        // 构造请求对象
        BTKQueryTrackLatestPointRequest *request = [[BTKQueryTrackLatestPointRequest alloc] initWithEntityName:entityName processOption: option outputCootdType:BTK_COORDTYPE_BD09LL serviceID:serviceID tag:1];
        // 发起查询请求
        [[BTKTrackAction sharedInstance] queryTrackLatestPointWith:request delegate:self];
    });
}

#pragma mark - BTKTraceDelegate
-(void)onStartService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_SERVICE_SUCCESS || error == BTK_START_SERVICE_SUCCESS_BUT_OFFLINE) {
        NSLog(@"轨迹服务开启成功");
        self.isServiceStarted = TRUE;
    } else {
        NSLog(@"轨迹服务开启失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_SERVICE_SUCCESS:
            title = @"轨迹服务开启成功";
            message = @"成功登录到服务端";
            break;
        case BTK_START_SERVICE_SUCCESS_BUT_OFFLINE:
            title = @"轨迹服务开启成功";
            message = @"当前网络不畅，未登录到服务端。网络恢复后SDK会自动重试";
            break;
        case BTK_START_SERVICE_PARAM_ERROR:
            title = @"轨迹服务开启失败";
            message = @"参数错误";
            break;
        case BTK_START_SERVICE_INTERNAL_ERROR:
            title = @"轨迹服务开启失败";
            message = @"SDK服务内部出现错误";
            break;
        case BTK_START_SERVICE_NETWORK_ERROR:
            title = @"轨迹服务开启失败";
            message = @"网络异常";
            break;
        case BTK_START_SERVICE_AUTH_ERROR:
            title = @"轨迹服务开启失败";
            message = @"鉴权失败，请检查AK和MCODE等配置信息";
            break;
        case BTK_START_SERVICE_IN_PROGRESS:
            title = @"轨迹服务开启失败";
            message = @"正在开启服务，请稍后再试";
            break;
        case BTK_SERVICE_ALREADY_STARTED_ERROR:
            title = @"轨迹服务开启失败";
            message = @"已经成功开启服务，请勿重复开启";
            break;
        default:
            title = @"通知";
            message = @"轨迹服务开启结果未知";
            break;
    }
    
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"title"] = title;
    body[@"message"] = message;
    [self sendEvent:@"onStartService" body:body];
}

-(void)onStopService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_SERVICE_NO_ERROR) {
        NSLog(@"轨迹服务停止成功");
        self.isServiceStarted = FALSE;
    } else {
        NSLog(@"轨迹服务停止失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_SERVICE_NO_ERROR:
            title = @"轨迹服务停止成功";
            message = @"SDK已停止工作";
            break;
        case BTK_STOP_SERVICE_NOT_YET_STARTED_ERROR:
            title = @"轨迹服务停止失败";
            message = @"还没有开启服务，无法停止服务";
            break;
        case BTK_STOP_SERVICE_IN_PROGRESS:
            title = @"轨迹服务停止失败";
            message = @"正在停止服务，请稍后再试";
            break;
        default:
            title = @"通知";
            message = @"轨迹服务停止结果未知";
            break;
    }
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"title"] = title;
    body[@"message"] = message;
    [self sendEvent:@"onStopService" body:body];
}

-(void)onStartGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_GATHER_SUCCESS) {
        NSLog(@"开始采集成功");
        self.isGatherStarted = TRUE;
    } else {
        NSLog(@"开始采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_GATHER_SUCCESS:
            title = @"开始采集成功";
            message = @"开始采集成功";
            break;
        case BTK_GATHER_ALREADY_STARTED_ERROR:
            title = @"开始采集失败";
            message = @"已经在采集轨迹，请勿重复开始";
            break;
        case BTK_START_GATHER_BEFORE_START_SERVICE_ERROR:
            title = @"开始采集失败";
            message = @"开始采集必须在开始服务之后调用";
            break;
        case BTK_START_GATHER_LOCATION_SERVICE_OFF_ERROR:
            title = @"开始采集失败";
            message = @"没有开启系统定位服务";
            break;
        case BTK_START_GATHER_LOCATION_ALWAYS_USAGE_AUTH_ERROR:
            title = @"开始采集失败";
            message = @"没有开启后台定位权限";
            break;
        case BTK_START_GATHER_INTERNAL_ERROR:
            title = @"开始采集失败";
            message = @"SDK服务内部出现错误";
            break;
        default:
            title = @"通知";
            message = @"开始采集轨迹的结果未知";
            break;
    }
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"title"] = title;
    body[@"message"] = message;
    [self sendEvent:@"onStartGather" body:body];
}

-(void)onStopGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_GATHER_NO_ERROR) {
        NSLog(@"停止采集成功");
        self.isGatherStarted = FALSE;
    } else {
        NSLog(@"停止采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_GATHER_NO_ERROR:
            title = @"停止采集成功";
            message = @"SDK停止采集本设备的轨迹信息";
            break;
        case BTK_STOP_GATHER_NOT_YET_STARTED_ERROR:
            title = @"开始采集失败";
            message = @"还没有开始采集，无法停止";
            break;
        default:
            title = @"通知";
            message = @"停止采集轨迹的结果未知";
            break;
    }
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"title"] = title;
    body[@"message"] = message;
    [self sendEvent:@"onStopGather" body:body];
}

#pragma mark - BTKTrackDelegate
-(void)onQueryHistoryTrack:(NSData *)response {
    NSMutableDictionary *body = [self getEmptyBody];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"HISTORY TRACK查询格式转换出错");
        body[@"title"] = @"格式转换出错";
        body[@"message"] = @"数据为空";
        [self sendEvent:@"onQueryTrackCacheInfo" body:body];
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"HISTORY TRACK查询返回错误");
        body[@"title"] = @"查询返回错误";
        body[@"message"] = dict[@"message"];
        [self sendEvent:@"onQueryTrackCacheInfo" body:body];
        return;
    }
    body[@"title"] = @"查询信息成功";
    body[@"message"] = dict[@"message"];
    body[@"points"] = dict[@"points"];

    [self sendEvent:@"onQueryHistoryTrack" body:body];
}

-(void)onQueryTrackLatestPoint:(NSData *)response {
    NSMutableDictionary *body = [self getEmptyBody];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Track LatestPoint查询格式转换出错");
        body[@"title"] = @"格式转换出错";
        body[@"message"] = @"数据为空";
        [self sendEvent:@"onQueryTrackCacheInfo" body:body];
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"实时位置查询返回错误");
        body[@"title"] = @"查询返回错误";
        body[@"message"] = dict[@"message"];
        [self sendEvent:@"onQueryTrackCacheInfo" body:body];
        return;
    }
    
    body[@"title"] = @"查询信息成功";
    body[@"message"] = dict[@"message"];
    body[@"point"] = dict[@"latest_point"];
    
    [self sendEvent:@"onQueryTrackLatestPoint" body:body];
}

@end
