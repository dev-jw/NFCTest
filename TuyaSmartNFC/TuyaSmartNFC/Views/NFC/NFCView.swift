//
//  NFCView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct NFCView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Tag")) {
                    Button(action: {
                        
//                        NFCTool.performAction(.readTag(device: device)) { (result) in
//                            deviceModel.isOnline = !deviceModel.isOnline
//                        }
                    }, label: {
                        Text("Scan Tag")
                    })
                    Button(action: {

//                        NFCTool.performAction(.writeTag(dps: str ?? "")) { (result) in
//                            print(result)
//                        }
                    }, label: {
                        Text("Write Tag")
                    })
                }
            }
            LoadingView(isLoading: self.store.state.activatorState.requesting)
        }
        .navigationBarTitle("NFC")
    }
}

struct NFCView_Previews: PreviewProvider {
    static var previews: some View {
        NFCView().environmentObject(AppMain().store)
    }
}
