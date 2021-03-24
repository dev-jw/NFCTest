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
            ScrollView {
                LazyVStack {
                    Section(header: HStack {
                        Text("Scan from tag")
                            .font(.headline)
                            .foregroundColor(Color.init("sectionTitleColor"))
                            .padding()
                        Spacer()
                    }
                    .background(Color.init("sectionColor"))
                    .listRowInsets(
                        EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: 0))
                    ) {
                        
                        RootRow(content: Text("Scan Tag")) {
                            NFCTool.performAction(.readTag)
                        }
                    }
                }
                LazyVStack {
                    Section(header: HStack {
                        Text("Write to tag")
                            .font(.headline)
                            .foregroundColor(Color.init("sectionTitleColor"))
                            .padding()
                        Spacer()
                    }
                    .background(Color.init("sectionColor"))
                    .listRowInsets(
                        EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: 0))
                    ) {
                        ForEach(store.state.deviceState.devices, id: \.self) { deviceModel in
                            RootRow(content: HStack {
                                Text(deviceModel.name).font(.system(size: 16, weight: .bold))
                                Spacer()
                                Text("on or off")
                            }
                            ) {
                                                                
                                let dict = ["dpId": "1", "devId": deviceModel.devId as Any] as [String : Any]
                                let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
                                
                                let str = String(data: data!, encoding: String.Encoding.utf8)
                                
                                NFCTool.performAction(.writeTag(dps: str ?? ""))
                                
                            }.animation(.easeIn(duration: 0.3))
                        }
                    }
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
