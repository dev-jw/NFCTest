//
//  AppState.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

struct AppState: StateType {
    var signState: SignState = .init()
    var authState: AuthState = .init()
    var homeState: HomeState = .init()
    var deviceState: DeviceState = .init()
    var activatorState: ActivatorState = .init()
}
