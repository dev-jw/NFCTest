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
    
    var device: TuyaSmartDevice?
    var schemaArray: [TuyaSmartSchemaModel] {
        get {
            return device?.deviceModel.schemaArray ?? []
        }
    }
    
    var dps: [AnyHashable : Any] {
        get {
            return device?.deviceModel.dps! ?? [:]
        }
        set {}
    }
}
