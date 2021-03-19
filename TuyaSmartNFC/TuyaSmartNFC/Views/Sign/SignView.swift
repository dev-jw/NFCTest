//
//  SignView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import AlertToast

struct RegisterView: View, Identifiable {
    var id = UUID()
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var code = "86"
    @State private var account = ""
    @State private var password = ""
    
    @State private var showToast = false
    @State private var showMessage: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        TextField("Enter Country Code", text: $code).autocapitalization(.words)
                        TextField("Enter Account", text: $account).autocapitalization(.words)
                        SecureField("Enter Password", text: $password).autocapitalization(.words)
                    }
                    Button(action: {
                        self.store.dispatch(SignAction.sendCode(with: self.code, account: self.account))
                    }) {
                        Text("Send Code")
                    }
                    .disabled(code.isEmpty || account.isEmpty)
                    
                    Button(action: {
                        self.store.dispatch(SignAction.signIn(with: self.code, account: self.account, password: self.password))
                    }) {
                        Text("Register")
                    }
                    .disabled(code.isEmpty || account.isEmpty || password.isEmpty)
                }
                .navigationTitle("Sign In")
                .toast(isPresenting: $showToast) { () -> AlertToast in
                    AlertToast(type: store.state.signState.requesting ? .loading : .regular, title: "\(showMessage)")
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onReceive(store.objectWillChange) { _ in
            if store.state.signState.error != nil {
                showToast = true
                showMessage = String(store.state.signState.error?.localizedDescription ?? "")
            } else if (store.state.signState.requesting) {
                showToast = true
                showMessage = ""
            } else {
                showToast = true
                showMessage = String("Operation Success")
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView().environmentObject(AppMain().store)
    }
}

struct SignView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var presentation: PresentationView?
    
    @State private var code = "86"
    @State private var account = ""
    @State private var password = ""
    
    @State private var showToast = false
    @State private var showMessage: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        TextField("Enter Country Code", text: $code).autocapitalization(.words)
                        TextField("Enter Account", text: $account).autocapitalization(.words)
                        SecureField("Enter Password", text: $password).autocapitalization(.words)
                    }
                    Button(action: {
                        self.store.dispatch(SignAction.signUp(with: self.code, account: self.account, password: self.password))
                    }) {
                        Text("Login")
                    }
                    .disabled(code.isEmpty || account.isEmpty || password.isEmpty)
                    
                }
                .navigationTitle("Login")
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.presentation = PresentationView(view: RegisterView())
                                        }) {Text("Sign In")})
                .sheet(item: $presentation, content: { $0.environmentObject(self.store) })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toast(isPresenting: $showToast) { () -> AlertToast in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
            return AlertToast(type: store.state.signState.requesting ? .loading : .regular, title: "\(showMessage)")
        }
        .onReceive(store.objectWillChange) { data in
            print("\(data)")
            if store.state.signState.error != nil {
                showToast = true
                showMessage = String(store.state.signState.error?.localizedDescription ?? "")
            } else if (store.state.signState.requesting) {
                showToast = true
                showMessage = ""
            } else {
                showToast = true
            }
        }
    }
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView().environmentObject(AppMain().store)
    }
}
