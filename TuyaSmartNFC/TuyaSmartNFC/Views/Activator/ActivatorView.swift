//
//  ActivatorView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartActivatorKit
import AlertToast

enum ActivatorType {
    case EZ
    case AP
    case GateWay
    case ZigBeeSub
    
    var titleMessage: String  {
        switch self {
        case .EZ:
            return "EZ Acitvator"
        case .AP:
            return "AP Acitvator"
        case .GateWay:
            return "GateWay Acitvator"
        case .ZigBeeSub:
            return "ZigBeeSub Acitvator"
        }
    }
    
    var model: TYActivatorMode  {
        switch self {
        case .EZ:
            return TYActivatorModeEZ
        case .AP:
            return TYActivatorModeAP
        default:
            return TYActivatorModeEZ
        }
    }
}

struct ActivatorView: View, Identifiable {
    var id = UUID()
    var type: ActivatorType
    
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var ssid = ""
    @State private var password = ""
    
    @State private var showToast = false
    @State private var showMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center) {
                    Form {
                        
                        if type == .EZ || type == .AP {
                            Section {
                                TextField("Enter Wifi", text: $ssid).autocapitalization(.words)
                                TextField("Enter Password", text: $password).autocapitalization(.words)
                            }
                            Section {
                                Button ("Start Activator") {
                                    if let window = UIApplication.shared.windows.first {
                                        window.endEditing(true)
                                    }
                                    store.dispatch(ActivatorAction.startConfig(with: type.model, ssid: ssid, password: password))
                                }
                                .disabled(ssid.isEmpty || password.isEmpty || store.state.activatorState.requesting)
                            }
                        }else {
                            Section {
                                Button ("Start Activator") {
                                    store.dispatch(ActivatorAction.startConfig(isSub: type == .ZigBeeSub))
                                }
                                .disabled(store.state.activatorState.requesting)
                            }
                        }
                        
                        Section {
                            Button("Stop Activator") {
                                if let window = UIApplication.shared.windows.first {
                                    window.endEditing(true)
                                }
                                if type == .ZigBeeSub {
                                    store.dispatch(ActivatorAction.stopConfig(isSub: true))
                                }else {
                                    store.dispatch(ActivatorAction.stopConfig())
                                }
                            }
                        }
                    }
                }
                LoadingView(isLoading: self.store.state.activatorState.requesting)
            }
            .navigationBarTitle(type.titleMessage)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toast(isPresenting: $showToast) { () -> AlertToast in
            return AlertToast(type:.regular, title: "\(showMessage)")
        }
        .onReceive(store.objectWillChange) { data in
            print("\(data)")
            if store.state.activatorState.error != nil {
                showToast = true
                showMessage = String(store.state.activatorState.error?.localizedDescription ?? "")
            } else if (!store.state.activatorState.res.isEmpty) {
                showToast = true
                showMessage = store.state.activatorState.res
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            self.store.dispatch(ActivatorAction.fetchToken())
        }
        .onDisappear {
            self.store.dispatch(ActivatorAction.stopConfig(isSub: type == .ZigBeeSub))
        }
    }
}

struct ActivatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivatorView(type: .EZ).environmentObject(AppMain().store)
    }
}
