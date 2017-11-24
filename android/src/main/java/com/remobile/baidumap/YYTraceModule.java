package com.remobile.baidumap;

import android.util.Log;

import com.baidu.trace.LBSTraceClient;
import com.baidu.trace.Trace;
import com.baidu.trace.api.track.HistoryTrackRequest;
import com.baidu.trace.api.track.HistoryTrackResponse;
import com.baidu.trace.api.track.LatestPoint;
import com.baidu.trace.api.track.LatestPointResponse;
import com.baidu.trace.api.track.OnTrackListener;
import com.baidu.trace.api.track.TrackPoint;
import com.baidu.trace.model.OnTraceListener;
import com.baidu.trace.model.PushMessage;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import com.baidu.trace.model.StatusCodes;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.util.List;

public class YYTraceModule extends BaseModule {

    private LBSTraceClient traceClient;
    private static Trace trace;
    /**
     * 轨迹服务监听器
     */
    private OnTraceListener traceListener = null;

    /**
     * 轨迹监听器(用于接收纠偏后实时位置回调)
     */
    private OnTrackListener trackListener = null;

    public YYTraceModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        initListener();
    }

    public String getName() {
        return "BaiduYYTraceModule";
    }


    private void initTraceClient() {
        traceClient = new LBSTraceClient(context.getApplicationContext());
        Log.i("traceClient", "traceClient");
    }
    /**
     *
     * @return
     */
    protected Trace getTrace(String entityName, Integer serviceId) {
        if(trace == null) {
            trace = new Trace(serviceId, entityName);
        }
        return trace;
    }

    @ReactMethod
    public void startService(String entityName, Integer serviceId) {
        if(traceClient == null) {
            initTraceClient();
        }
        traceClient.startTrace(getTrace(entityName, serviceId), traceListener);
    }

    @ReactMethod
    public void stopService() {
        traceClient.stopTrace(trace, traceListener);
    }

    @ReactMethod
    public void startGather() {
        traceClient.startGather(traceListener);
    }

    @ReactMethod
    public void stopGather() {
        traceClient.stopGather(traceListener);
    }

    @ReactMethod
    public void queryHistoryTrack (String entityName, Integer serviceId) {
        if(traceClient == null) {
            initTraceClient();
        }
        // 创建历史轨迹请求实例
        HistoryTrackRequest historyTrackRequest = new HistoryTrackRequest(1, serviceId, entityName);
        //设置轨迹查询起止时间
        // 开始时间(单位：秒)
        long startTime = System.currentTimeMillis() / 1000 - 12 * 60 * 60;
        // 结束时间(单位：秒)
        long endTime = System.currentTimeMillis() / 1000;
        // 设置开始时间
        historyTrackRequest.setStartTime(startTime);
        // 设置结束时间
        historyTrackRequest.setEndTime(endTime);
        // 查询历史轨迹
        traceClient.queryHistoryTrack(historyTrackRequest, trackListener);

    }

    private void initListener() {
        trackListener = new OnTrackListener() {
            @Override
            public void onHistoryTrackCallback(HistoryTrackResponse response) {
                WritableMap params = Arguments.createMap();
                if (StatusCodes.SUCCESS != response.getStatus()) {
                    params.putString("title", "格式转换出错");
                    params.putString("message", response.getMessage());
                } else if (0 == response.getTotal()) {
                    params.putString("title", "查询返回错误");
                    params.putString("message", response.getMessage());
                } else {
                    params.putString("title", "查询成功");
                    params.putString("message", response.getMessage());
                    List<TrackPoint> points = response.getTrackPoints();
                    WritableArray writableArray = new WritableNativeArray();
                    if (null != points) {
                        for (TrackPoint trackPoint : points) {
                            if (!MarkerUtil.isZeroPoint(trackPoint.getLocation().getLatitude(),trackPoint.getLocation().getLongitude())) {
                                WritableMap writableMap = new WritableNativeMap();
                                writableMap.putDouble("longitude", trackPoint.getLocation().getLongitude());
                                writableMap.putDouble("latitude", trackPoint.getLocation().getLatitude());
                                writableArray.pushMap(writableMap);
                            }
                        }
                    }
                    params.putArray("points", writableArray);
                }
                sendEvent("onQueryHistoryTrack", params);
            }
        };
        traceListener = new OnTraceListener() {
            @Override
            public void onBindServiceCallback(int i, String s) {

            }

            /**
             * 开启服务回调接口
             * @param errorNo 状态码
             * @param message 消息
             * <p>
             * <pre>0：成功 </pre>
             * <pre>10000：请求发送失败</pre>
             * <pre>10001：服务开启失败</pre>
             * pre>10002：参数错误</pre>
             * <pre>10003：网络连接失败</pre>
             * <pre>10004：网络未开启</pre>
             * <pre>10005：服务正在开启</pre>
             * <pre>10006：服务已开启</pre>
             */
            @Override
            public void onStartTraceCallback(int errorNo, String message) {
                WritableMap params = Arguments.createMap();
                params.putInt("errorNo", errorNo);
                params.putString("message", message);
                sendEvent("onStartService", params);
            }

            /**
             * 停止服务回调接口
             * @param errorNo 状态码
             * @param message 消息
             * <p>
             * <pre>0：成功</pre>
             * <pre>11000：请求发送失败</pre>
             * <pre>11001：服务停止失败</pre>
             * <pre>11002：服务未开启</pre>
             * <pre>11003：服务正在停止</pre>
             */
            @Override
            public void onStopTraceCallback(int errorNo, String message) {
                WritableMap params = Arguments.createMap();
                params.putInt("errorNo", errorNo);
                params.putString("message", message);
                sendEvent("onStopService", params);
            }

            /**
             * 开启采集回调接口
             * @param errorNo 状态码
             * @param message 消息
             * <p>
             * <pre>0：成功</pre>
             * <pre>12000：请求发送失败</pre>
             * <pre>12001：采集开启失败</pre>
             * <pre>12002：服务未开启</pre>
             */
            @Override
            public void onStartGatherCallback(int errorNo, String message) {
                WritableMap params = Arguments.createMap();
                params.putInt("errorNo", errorNo);
                params.putString("message", message);
                sendEvent("onStartGather", params);
            }

            /**
             * 停止采集回调接口
             * @param errorNo 状态码
             * @param message 消息
             * <p>
             * <pre>0：成功</pre>
             * <pre>13000：请求发送失败</pre>
             * <pre>13001：采集停止失败</pre>
             * <pre>13002：服务未开启</pre>
             */
            @Override
            public void onStopGatherCallback(int errorNo, String message) {
                WritableMap params = Arguments.createMap();
                params.putInt("errorNo", errorNo);
                params.putString("message", message);
                sendEvent("onStopGather", params);
            }

            @Override
            public void onPushCallback(byte b, PushMessage pushMessage) {

            }

            @Override
            public void onInitBOSCallback(int i, String s) {

            }
        };
    }
}
