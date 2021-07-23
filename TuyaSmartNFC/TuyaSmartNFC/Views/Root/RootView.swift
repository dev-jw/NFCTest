//
//  RootView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

class ActivatorActionSheetState: ObservableObject {
    @Published var showActionSheet: Bool = false
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    
    @ObservedObject private var activatorActionSheetState: ActivatorActionSheetState = .init()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var presentation: PresentationView?
    
    @State var isPushedHome = false
    @State var isPushedNFC = false
    @State var isPushedScene = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack { EmptyView() }
                    ZStack {
                        ScrollView {
                            LazyVStack(content: {
                                Section(header: HStack {
                                    Text("Home")
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
                                    NavigationLink(destination: HomeListView(),
                                                   isActive: $isPushedHome) {
                                        
                                        RootRow(content: Text(store.state.homeState.currentHome?.homeModel.name ?? "Create Home")) {
                                            isPushedHome = true
                                        }
                                    }
                                }
                                
                            })
                            LazyVStack(content: {
                                Section(header: HStack {
                                    Text("Devices")
                                        .font(.headline)
                                        .foregroundColor(Color.init("sectionTitleColor"))
                                        .padding()
                                    Spacer()
                                    CircleSystemButton(action:  {
                                        activatorActionSheetState.showActionSheet = true
                                    })
                                    .padding()
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
                                            VStack(alignment: .leading) {
                                                Text("Name: \(deviceModel.name)").font(.system(size: 16, weight: .bold))
                                                Spacer().frame(height: 10)
                                                Text("Online statu: \(String(deviceModel.isOnline))")
                                                    .foregroundColor(.gray).font(.system(size: 12))
                                            }
                                        }) {
                                            
                                            if deviceModel.isOnline {
                                                self.presentation = PresentationView(view: PanelView(devId: deviceModel.devId))
                                            }
                                            
                                        }.animation(.easeIn(duration: 0.3))
                                    }
                                }
                            })
                        }
                        CircleSystemButton(systemName: "n.circle.fill", action:  {
                            isPushedNFC = true
                        })
                        .offset(x: 70 - UIScreen.main.bounds.width, y: -16)
                        NavigationLink(destination: NFCView(), isActive: $isPushedNFC) { EmptyView() }
                        
                        CircleSystemButton(systemName: "s.circle.fill",action:  {
                            isPushedScene = true
                        })
                        .offset(x: -32, y: -16)
                        NavigationLink(destination: SceneView(), isActive: $isPushedScene) { EmptyView() }
                    }
                    .layoutPriority(1)
                }
                LoadingView(isLoading: self.store.state.deviceState.requesting)
            }
            .navigationBarTitle("Devices")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        self.presentation = PresentationView(view: ProfileView())
                                    }) {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 30.0, height: 30.0)
                                    })
            .sheet(item: $presentation, content: { $0.environmentObject(self.store) })
            .actionSheet(isPresented: $activatorActionSheetState.showActionSheet) {
                ActionSheet(
                    title: Text(""),
                    message: Text("Please choose one of the following ways"),
                    buttons: [
                        ActionSheet.Button.default(Text("NFC Activator")) {
                            self.presentation = PresentationView(view: ActivatorView(type: .NFC))
                        },
                        
                        ActionSheet.Button.default(Text("EZ Activator")) {
                            self.presentation = PresentationView(view: ActivatorView(type: .EZ))
                        },
                        
                        ActionSheet.Button.default(Text("AP Activator")) {
                            self.presentation = PresentationView(view: ActivatorView(type: .AP))
                        },
                        
                        ActionSheet.Button.default(Text("GateWay Activator")) {
                            self.presentation = PresentationView(view: ActivatorView(type: .GateWay))
                        },
                        
                        ActionSheet.Button.default(Text("ZigBee Sub Activator")) {
                            self.presentation = PresentationView(view: ActivatorView(type: .ZigBeeSub))
                        },
                        ActionSheet.Button.cancel(),
                    ]
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { self.store.dispatch(DeviceAction.subscribe()) }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(AppMain().store)
    }
}
