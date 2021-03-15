//
//  HomeListUI.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartDeviceKit

struct HomeListUI: View {
    @ObservedObject var help = HomeHelp.shared
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            List {
                ForEach(help.homeList ?? [], id: \.self) { row in
                    Button (row.name) {
                        help.configCurrentHome(row.homeId)
                        help.fetchDevices()
                        self.mode.wrappedValue.dismiss()
                    }
                }.onDelete(perform: help.deleteHome(at:))
            }
            Button ("Create New Home") {
                //增加
               let homeId = help.createHome()
                help.configCurrentHome(homeId)
                help.fetchDevices()
            }
        }
        .navigationBarTitle("Home List")
    }
}

struct HomeListUI_Previews: PreviewProvider {
    static var previews: some View {
        HomeListUI()
    }
}
