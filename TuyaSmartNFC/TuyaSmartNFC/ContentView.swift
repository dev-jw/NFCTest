//
//  ContentView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartDeviceKit

struct ContentView: View {
    @ObservedObject var help = HomeHelp.shared
    @State var currentDevice: TuyaSmartDevice?
    
    @State var isPushed = false
    
    private var homeSection: some View {
        Section(header: Text("Home")) {
            
            Button(action: {
                isPushed = true
            }, label: {
                
                NavigationLink(destination: HomeListUI(),
                               isActive: $isPushed) {
                    Text(help.currentHome?.name ?? " Create Home")
                }
            })
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
    
    private var activatorSection: some View {
        Section(header: Text("Activator")) {
            List {
                NavigationLink(destination: EZActivatorContent()) {
                    Text("EZ Activator")
                }
                NavigationLink(destination: APActivatorContent()) {
                    Text("AP Activator")
                }
                NavigationLink(destination: GateWayActivatorContent()) {
                    Text("GateWay Activator")
                }
                NavigationLink(destination: ZigBeeSubActivatorContent()) {
                    Text("ZigBee Sub Activator")
                }
            }
        }
    }
    
    private var sceneSection: some View {
        Section(header: Text("Scene")) {
            NavigationLink(destination: SceneContent()) {
                Text("Create Scene")
            }
        }
    }
    
    private var NFCSection: some View {
        Section(header: Text("NFC")) {
            NavigationLink(destination: NFCContent()) {
                Text("NFC Operation")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                homeSection
                deviceSection
                activatorSection
                sceneSection
                NFCSection
                Button(action: {
                    loginOut()
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
    
    func loginOut() {
        TuyaSmartUser.sharedInstance().loginOut {
            
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.endEditing(true)
                window.makeKeyAndVisible()
            }
        } failure: { (error) in
            print("login out error: \(String(describing: error?.localizedDescription))")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
