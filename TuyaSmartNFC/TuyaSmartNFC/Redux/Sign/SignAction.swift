//
//  SignAction.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import ReSwiftThunk
import TuyaSmartBaseKit

enum SignAction: Action {
    case signInStarted
    case signInFinished
    case signInFailed(error: Error)
    
    case signUpStarted
    case signUpFinished
    case signUpFailed(error: Error)

    static func signIn(with code: String, account: String, password: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            if getState()?.signState.requesting == true {
                return
            }
            
            dispatch(SignAction.signInStarted)
            TuyaSmartUser.sharedInstance().register(byPhone: code, phoneNumber: account, password: password, code: "433841") {
                dispatch(SignAction.signInFinished)
            } failure: { (error) in
                dispatch(SignAction.signInFailed(error: error!))
            }
        }
    }
    
    static func sendCode(with code: String, account: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            if getState()?.signState.requesting == true {
                return
            }
            
            TuyaSmartUser.sharedInstance().sendVerifyCode(withUserName: account, region: "AY", countryCode: code, type: 1) {
                print("send success")
            } failure: { (error) in
                print("send code error: \(String(describing: error?.localizedDescription))")
                dispatch(SignAction.signInFailed(error: error!))
            }            
        }
    }
    
    static func signUp(with code: String, account: String, password: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            if getState()?.signState.requesting == true {
                return
            }
            
            dispatch(SignAction.signUpStarted)
            TuyaSmartUser.sharedInstance().login(byPhone: code, phoneNumber: account, password: password) {
                dispatch(SignAction.signUpFinished)
                dispatch(AuthAction.updateLogin(login: true))
            } failure: { (error) in
                dispatch(SignAction.signUpFailed(error: error!))
            }
        }
    }
}
