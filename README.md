# React Native Baidu Map (remobile)
A baidu map for react-native, support for ios and android
this project is copy from https://github.com/lovebing/react-native-baidu-map, just use for personal project use.
thanks https://github.com/lovebing/react-native-baidu-map.

### Installation
npm install @remobile/react-native-baidu-map --save

### Installation (Android)
- settings.gradle `
include ':react-native-baidu-map'
project(':react-native-baidu-map').projectDir = new File(settingsDir, '../node_modules/@remobile/react-native-baidu-map/android')`

- build.gradle `compile project(':react-native-baidu-map')`

- MainApplication`new BaiduMapPackage(getApplicationContext())`
- AndroidMainifest.xml `<meta-data android:name="com.baidu.lbsapi.API_KEY" android:value="xx"/>`

### Installation (iOS)
- Project navigator->Libraries->Add Files to 选择 @remobile/react-native-baidu-map/ios/RCTBaiduMap.xcodeproj
- Project navigator->Build Phases->Link Binary With Libraries 加入 libRCTBaiduMap.a
- Project navigator->Build Settings->Search Paths， Framework search paths 添加 @remobile/react-native-baidu-map/ios/lib，Header search paths 添加 @remobile/react-native-baidu-map/ios/RCTBaiduMap
- 添加依赖, @remobile/react-native-baidu-map/ios/lib 下的全部 framwordk， CoreLocation.framework和QuartzCore.framework、OpenGLES.framework、SystemConfiguration.framework、CoreGraphics.framework、Security.framework、libsqlite3.0.tbd（xcode7以前为 libsqlite3.0.dylib）、CoreTelephony.framework 、libstdc++.6.0.9.tbd（xcode7以前为libstdc++.6.0.9.dylib）
- 添加 BaiduMapAPI_Map.framework/Resources/mapapi.bundle

- 其它一些注意事项可参考百度地图LBS文档

##### AppDelegate.m init 初始化
    #import "RCTBaiduMapViewManager.h"
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        ...
        [RCTBaiduMapViewManager initSDK:@"api key"];
        ...
    }

### Usage 使用方法

    import { MapView, MapTypes, MapModule, Geolocation } from 'react-native-baidu-map

#### MapView Props 属性
| Name                    | Type  | Default  | Extra
| ----------------------- |:-----:| :-------:| -------
| zoomControlsVisible     | bool  | true     | Android only
| trafficEnabled          | bool  | false    |
| baiduHeatMapEnabled     | bool  | false    |
| mapType                 | number| 1        |
| zoom                    | number| 10       |
| center                  | object| null     | {latitude: 0, longitude: 0}
| marker                  | object| null     | {latitude: 0, longitude: 0, title: ''}
| markers                 | array | []       | [marker, maker]
| onMapStatusChangeStart  | func  | undefined| Android only
| onMapStatusChange       | func  | undefined|
| onMapStatusChangeFinish | func  | undefined| Android only
| onMapLoaded             | func  | undefined|
| onMapClick              | func  | undefined|
| onMapDoubleClick        | func  | undefined|
| onMarkerClick           | func  | undefined|
| onMapPoiClick           | func  | undefined|

#### MapModule Methods (Deprecated)
    setMarker(double lat, double lng)
    setMapType(int mapType)
    moveToCenter(double lat, double lng, float zoom)
    Promise reverseGeoCode(double lat, double lng)
    Promise reverseGeoCodeGPS(double lat, double lng)
    Promise geocode(String city, String addr),
    Promise getCurrentPosition()

#### Geolocation Methods

| Method                    | Result
| ------------------------- | -------
| Promise reverseGeoCode(double lat, double lng) | `{"address": "", "province": "", "cityCode": "", "city": "", "district": "", "streetName": "", "streetNumber": ""}`
| Promise reverseGeoCodeGPS(double lat, double lng) |  `{"address": "", "province": "", "cityCode": "", "city": "", "district": "", "streetName": "", "streetNumber": ""}`
| Promise geocode(String city, String addr) | {"latitude": 0.0, "longitude": 0.0}
| Promise getCurrentPosition() | IOS: `{"latitude": 0.0, "longitude": 0.0, "address": "", "province": "", "cityCode": "", "city": "", "district": "", "streetName": "", "streetNumber": ""}` Android: `{"latitude": 0.0, "longitude": 0.0, "direction": -1, "altitude": 0.0, "radius": 0.0, "address": "", "countryCode": "", "country": "", "province": "", "cityCode": "", "city": "", "district": "", "street": "", "streetNumber": "", "buildingId": "", "buildingName": ""}`
