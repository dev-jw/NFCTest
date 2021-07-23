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
//                            NFCTool.performAction(.readTag)
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
                                                                                                
                                let homeId = store.state.homeState.currentHome?.homeModel.homeId

                                let tool = NFCTool()
                                tool.startSession()
                                tool.write(withHomeId: homeId!)
                                
                            }.animation(.easeIn(duration: 0.3))
                        }
                    }
                }
                LazyVStack {
                    Section(header: HStack {
                        Text("Test Tag PWD")
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
                        
                        RootRow(content: Text("Test Tag")) {
                            
                            let homeId = store.state.homeState.currentHome?.homeModel.homeId

                            let tool = NFCTool()
                            tool.startSession()
                            tool.write(withHomeId: homeId!)

//                            TYNFCTool.sharedInstance().recordModifier = TYNFCRecordModifier(block: { (strings) -> [String]? in
//                                return [ANDROID_PACKAGE_PAYLOAD, APPLINKS]
//                            })
//
//                            TYNFCTool.sharedInstance().wirteToTag(withHomeId: homeId!, data: ["":""]) { data in
//                                print(data);
//                            } failure: { error in
//                                print(error?.localizedDescription ?? "")
//                            }
                            
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
