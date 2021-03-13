//
//  LoginView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct LoginView: View {
    @State private var code = "86"
    @State private var account = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter Country Code", text: $code).autocapitalization(.words)
                    TextField("Enter Account", text: $account).autocapitalization(.words)
                    SecureField("Enter Password", text: $password).autocapitalization(.words)
                }
                Button(action: {
                    LoginHelp.confirmLogin(code, account, password)
                }) {
                   Text("Login")
                }
                .disabled(code.isEmpty || account.isEmpty || password.isEmpty)
                
//                Button(action: {
//                    LoginHelp.sendCode()
//                }) {
//                   Text("Send Code")
//                }
//
//                Button(action: {
//                    LoginHelp.register()
//                }) {
//                   Text("Regist")
//                }
            }
            .navigationTitle("Login")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
