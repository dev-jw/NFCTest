//
//  ActivatorHelp.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import TuyaSmartActivatorKit

class ActivatorHelp: ObservableObject {
    
    private let help = HomeHelp.shared
    
    @Published var token: String? = nil
    
    func getToken() {
        guard let homeId = help.currentHome?.homeId else { return }
        TuyaSmartActivator.sharedInstance()?.getTokenWithHomeId(homeId, success: { [self] (result) in
            token = result!
        }, failure: { error in
            print("get Token error: \(String(describing: error?.localizedDescription))")
        })
    }
    
    func startConfig(mode: TYActivatorMode, ssid: String?, password: String?) {
        let token = self.token
        switch mode {
        case TYActivatorModeEZ:
            TuyaSmartActivator.sharedInstance()?.startConfigWiFi(mode, ssid: ssid, password: password, token: token, timeout: 120)
            break;
        case TYActivatorModeAP:
            TuyaSmartActivator.sharedInstance()?.startConfigWiFi(mode, ssid: ssid, password: password, token: token, timeout: 120)
            break;
        default:
            break;
        }
    }
    
    func startConfig() {
        TuyaSmartActivator.sharedInstance()?.startConfigWiFi(withToken: token, timeout: 120)
    }

    func startConfig(_ gwId: String) {
        TuyaSmartActivator.sharedInstance()?.activeSubDevice(withGwId: gwId, timeout: 120)
    }
    
}
