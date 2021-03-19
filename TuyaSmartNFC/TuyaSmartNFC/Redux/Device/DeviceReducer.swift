//
//  DeviceReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum DeviceReducer {
    static var reducer: Reducer<DeviceState> {
        return { action, state in
            var state = state ?? DeviceState()
            guard let action = action as? DeviceAction else {
                return state
            }
            switch action {
            case .updateDevices(let devices):
                state.devices = devices
                state.requesting = false
                state.error = nil
                return state
            case .operatorfailed(error: let error):
                state.requesting = false
                state.error = error
                return state
            case .startDeleteDevice:
                state.requesting = true
                state.error = nil
                return state
            }
        }
    }
}
