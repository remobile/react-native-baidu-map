import {
    requireNativeComponent,
    NativeModules,
    Platform,
    DeviceEventEmitter
} from 'react-native';

import React, {
    Component,
    PropTypes
} from 'react';


const _module = NativeModules.BaiduYYTraceModule;

export default {
    startService(entityName) {
        return new Promise((resolve, reject) => {
            try {
                _module.startService(entityName);
            }
            catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('onStartService', resp => {
                resolve(resp);
            });
        });
    },
    stopService() {
        return new Promise((resolve, reject) => {
            try {
                _module.stopService();
            }
            catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('onStopService', resp => {
                resolve(resp);
            });
        });
    },
    startGather() {
        return new Promise((resolve, reject) => {
            try {
                _module.startGather();
            }
            catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('onStartGather', resp => {
                resolve(resp);
            });
        });
    },
    stopGather() {
        return new Promise((resolve, reject) => {
            try {
                _module.stopGather();
            }
            catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('onStopGather', resp => {
                resolve(resp);
            });
        });
    },
    queryHistoryTrack(entityName, serviceID)  {
        return new Promise((resolve, reject) => {
            try {
                _module.queryHistoryTrack(entityName, serviceID);
            }
            catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('onQueryHistoryTrack', resp => {
                resolve(resp);
            });
        });
    }
};
