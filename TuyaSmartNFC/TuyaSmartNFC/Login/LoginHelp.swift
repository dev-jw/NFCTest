//
//  LoginHelp.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import SwiftUI
import Foundation
import TuyaSmartBaseKit

struct LoginHelp {
    static func confirmLogin(_ code: String, _ account: String, _ password: String) {
        print("login with account: \(account)")
        
        TuyaSmartUser.sharedInstance().login(byPhone: code, phoneNumber: account, password: password) {
         print("login success")
            
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView())
                window.endEditing(true)
                window.makeKeyAndVisible()
            }
        } failure: { error in
            print("login failure: \(String(describing: error?.localizedDescription))")
        }
    }
    
    static func sendCode() {
        
        TuyaSmartUser.sharedInstance().sendVerifyCode(withUserName: "13093770100", region: "AY", countryCode: "86", type: 1) {
            print("send success")

        } failure: { (error) in
            print("send code error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    static func register() {
        TuyaSmartUser.sharedInstance().register(byPhone: "86", phoneNumber: "13093770100", password: "123123", code: "433841") {
            print("register success")
        } failure: { (error) in
            print("register code error: \(String(describing: error?.localizedDescription))")

        }
    }
}

