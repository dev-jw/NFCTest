//
//  GateWayActivatorContent.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartActivatorKit

struct GateWayActivatorContent: View {
    @ObservedObject var help = ActivatorHelp()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Button("Start Activator") {
                        //增加
                        help.startConfig()
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

struct GateWayActivatorContent_Previews: PreviewProvider {
    static var previews: some View {
        GateWayActivatorContent()
    }
}
