//
//  NFCContent.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartDeviceKit

struct NFCContent: View {

    @ObservedObject var help = HomeHelp.shared

    private var operationSection: some View {
        Section(header: Text("Tag")) {
            Button(action: {
                guard let count = help.devices?.count, count > 0 else {
                    
                    return
                }
                
                let deviceModel = help.devices!.first!

                guard let devId = deviceModel.devId else {
                    return
                }
                
                let device = TuyaSmartDevice.init(deviceId: devId)
                
                NFCTool.performAction(.readTag(device: device)) { (result) in
                    deviceModel.isOnline = !deviceModel.isOnline
                }
            }, label: {
                Text("Scan Tag")
            })
            Button(action: {
                guard let count = help.devices?.count, count > 0 else { return }
                
                let device = help.devices!.first!
                
                let dict = ["dp":"1", "devId": device.devId]
                let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
                
                let str = String(data: data!, encoding: String.Encoding.utf8)
                
                NFCTool.performAction(.writeTag(dps: str ?? "")) { (result) in
                    print(result)
                }
            }, label: {
                Text("Write Tag")
            })
        }
    }
    
    var body: some View {
        Form {
            operationSection
        }
        .navigationBarTitle("NFC")
    }}

struct NFCContent_Previews: PreviewProvider {
    static var previews: some View {
        NFCContent()
    }
}
