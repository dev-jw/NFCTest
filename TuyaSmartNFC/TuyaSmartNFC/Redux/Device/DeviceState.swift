//
//  DeviceState.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import TuyaSmartDeviceKit

struct DeviceState: StateType {
    var requesting: Bool = false
    var error: Error?
    
    var devices: [TuyaSmartDeviceModel] = []
}
