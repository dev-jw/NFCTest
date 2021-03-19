//
//  AppReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum AppReducer {
    static var reducer: Reducer<AppState> {
        return { action, state in
            var state = state ?? AppState()
            state.signState = SignReducer.reducer(action, state.signState)
            state.authState = AuthReducer.reducer(action, state.authState)
            state.homeState = HomeReducer.reducer(action, state.homeState)
            state.deviceState = DeviceReducer.reducer(action, state.deviceState)
            state.activatorState = ActivatorReducer.reducer(action, state.activatorState)
            return state
        }
    }
}
