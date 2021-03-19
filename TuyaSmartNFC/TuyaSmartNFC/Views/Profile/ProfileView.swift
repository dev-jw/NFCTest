//
//  ProfileView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartBaseKit

struct ProfileView: View, Identifiable {
    var id = UUID()
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let infos = ["UserName", "PhoneNumber", "Email", "RegionCode", "TimezoneId", "CountryCode"]
    
    private var values = [
        TuyaSmartUser.sharedInstance().userName,
        TuyaSmartUser.sharedInstance().phoneNumber,
        TuyaSmartUser.sharedInstance().email,
        TuyaSmartUser.sharedInstance().regionCode,
        TuyaSmartUser.sharedInstance().timezoneId,
        TuyaSmartUser.sharedInstance().countryCode]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info")) {
                    ForEach(0..<infos.count) { idx in
                        Text("\(infos[idx]): \(values[idx])")
                    }
                }
                Section {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.store.dispatch(AuthAction.signOut())
                        
                    }) { Text("Sign Out") }
                }
            }
            .navigationTitle(Text("Information"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AppMain().store)
    }
}
