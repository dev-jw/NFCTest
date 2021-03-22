//
//  PanelView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct PanelView: View, Identifiable {
    var id = UUID()
    var devId: String
    
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            VStack {
                HStack { EmptyView() }
                ZStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(0..<store.state.deviceState.schemaArray.count, id: \.self) { idx in
                                PanelRow(schemaModel: store.state.deviceState.schemaArray[idx])
                            }
                        }
                        LoadingView(isLoading: self.store.state.deviceState.requesting)
                    }
                }
            }
            .navigationBarTitle("Panel")
            .navigationBarItems(trailing:
                                    Text("Delete").foregroundColor(.red).onTapGesture {
                                        store.dispatch(DeviceAction.delete(with: devId))
                                    })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.store.dispatch(DeviceAction.initDevice(with: devId))
        }
    }
}

struct PanelView_Previews: PreviewProvider {
    static var previews: some View {
        PanelView(devId: "").environmentObject(AppMain().store)
    }
}
