//
//  APActivatorContent.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartActivatorKit

struct APActivatorContent: View {
    @ObservedObject var help = ActivatorHelp()
    
    @State private var ssid = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter Wifi", text: $ssid).autocapitalization(.words)
                    TextField("Enter Password", text: $password).autocapitalization(.words)
                }
                Section {
                    Button ("Start Activator") {
                        //增加
                        help.startConfig(mode: TYActivatorModeAP, ssid: ssid, password: password)
                    }
                    .disabled(ssid.isEmpty || password.isEmpty)
                }
                Section {
                    Button("Stop Activator") {
                        
                    }
                }
                
            }
        }
        .navigationBarTitle("AP Activator")
        .onAppear {
            help.getToken()
        }
    }
}

struct APActivatorContent_Previews: PreviewProvider {
    static var previews: some View {
        APActivatorContent()
    }
}
