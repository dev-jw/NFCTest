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
            ZStack {
                LoadingView(isLoading: self.store.state.activatorState.requesting)
            }
            .navigationBarTitle("Panel")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PanelView_Previews: PreviewProvider {
    static var previews: some View {
        PanelView(devId: "").environmentObject(AppMain().store)
    }
}
