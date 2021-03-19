//
//  HomeState.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import TuyaSmartDeviceKit

struct HomeState: StateType {
    var requesting: Bool = false
    var error: Error?
    
    var currentHome: TuyaSmartHome?
    var homes: [TuyaSmartHomeModel] = []
}

struct Home {
    static var current: TuyaSmartHome? {
        get {
            let defaults = UserDefaults.standard
            guard let homeID = defaults.string(forKey: "CurrentHome") else { return nil }
            guard let id = Int64(homeID)  else { return nil }
            return TuyaSmartHome.init(homeId: id)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue?.homeModel.homeId, forKey: "CurrentHome")
        }
    }
}
