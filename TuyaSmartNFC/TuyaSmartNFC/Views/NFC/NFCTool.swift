//
//  NFCTool.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import TuyaSmartActivatorKit

class NFCTool: NSObject {

    func startSession() {
        
        TYNFCModuleService.sharedInstance.newReaderSession(with: self, alertMessage: "Hold your phone near the tag to begin")
        
        TYNFCModuleService.sharedInstance.recordModifier = TYNFCRecordModifier(block: { (strings) -> [String]? in
            return [ANDROID_PACKAGE_PAYLOAD, APPLINKS]
        })
    }
    
    func write(withHomeId homeId : Int64) {
        TYNFCModuleService.sharedInstance.write(withHomeId: homeId, data: ["" : ""])
        
        TYNFCModuleService.sharedInstance.begin()
    }
 
    func configWifi(withHomeId homeId: Int64, ssid: String, password: String, token: String) {
        
        
        let instance = TuyaSmartActivator.sharedInstance()
        instance?.startNFCConfigWiFi(withSsid: ssid, password: password, token: token, timeout: 100)
        
        
//        TYNFCModuleService.sharedInstance.writeActivationData(withHomeId: homeId, wifi: ssid, password: password, token: token)
//
//        TYNFCModuleService.sharedInstance.begin()
    }
    
}

// MARK: - NFCTagReaderSessionDelegate
extension NFCTool: TYNFCModuleServiceDelegate {
    func readerService(_ service: TYNFCModuleService, didInvalidateWithError error: Error) {
        
    }
    
    func readerServiceDidSuccessed(_ service: TYNFCModuleService) {
        
    }
}

