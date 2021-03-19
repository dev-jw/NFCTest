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
