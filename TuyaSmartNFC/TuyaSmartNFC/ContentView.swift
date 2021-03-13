//
//  ContentView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartDeviceKit

struct ContentView: View {
    @ObservedObject var help = HomeHelp()
    @State var currentDevice: TuyaSmartDevice?

    private var homeSection: some View {
        Section(header: Text("Home")) {
            Text(help.currentHome?.homeModel.name ?? "暂无家庭")
        }
    }
    
    private var deviceSection: some View {
        Section(header: Text("Device")) {
            ForEach(help.devices ?? [], id: \.self) {
                device in
                VStack(alignment: .leading, spacing: 10.0, content: {
                    Text("Device Name: \(device.name)")
                    Text("status: \(String(device.isOnline))")
                })
            }
        }
    }
    
    private var operationSection: some View {
        Section(header: Text("Tag")) {
            Button(action: {
                guard let deviceModel = help.devices?.first else { return }

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
                guard let device = help.devices?.first else { return }
                
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
        NavigationView {
          Form {
            homeSection
            deviceSection
            operationSection
            Button(action: {
                HomeHelp.loginOut()
            }, label: {
                Text("Login Out")
            })
          }
          .navigationBarTitle("Device List")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            help.initiateCurrentHome()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
