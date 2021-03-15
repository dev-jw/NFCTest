//
//  ZigBeeSubActivatorContent.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartActivatorKit

struct ZigBeeSubActivatorContent: View {
    @ObservedObject var help = ActivatorHelp()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Button("Start Activator") {
                        //增加
                        let home = HomeHelp.shared
                        var gatewayDevice: TuyaSmartDeviceModel?
                        home.devices?.forEach({ (deviceModel) in
                            if (deviceModel.deviceType == TuyaSmartDeviceModelTypeZigbeeGateway && deviceModel.isOnline) {
                                gatewayDevice = deviceModel
                            }
                        })
                        
                        guard let gateway = gatewayDevice else {
                            return
                        }
                        help.startConfig(gateway.devId)
                    }
                }
                Section {
                    Button("Stop Activator") {
                        
                    }
                }
            }
        }
        .navigationBarTitle("GateWay Activator")
        .onAppear {
            help.getToken()
        }
    }
}

struct ZigBeeSubActivatorContent_Previews: PreviewProvider {
    static var previews: some View {
        ZigBeeSubActivatorContent()
    }
}
