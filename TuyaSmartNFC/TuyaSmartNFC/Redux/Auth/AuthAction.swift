//
//  AuthAction.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Combine
import Foundation
import ReSwift
import ReSwiftThunk
import TuyaSmartBaseKit


enum AuthAction: Action {
    case finishInitialLoad
    case updateAuthChangeListener(listener: AnyCancellable?)
    case updateLogin(login: Bool)
    
    static func subscribe() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            let finishInitialLoad = {
                if getState()?.authState.loadingState == .initial {
                    dispatch(AuthAction.finishInitialLoad)
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: Selector(String("sessionInvalid")), name: NSNotification.Name(rawValue: TuyaSmartUserNotificationUserSessionInvalid), object: nil)
            
            finishInitialLoad()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                if TuyaSmartUser.sharedInstance().isLogin  {
                    dispatch(AuthAction.updateLogin(login: true))

                    guard let home = Home.current else {
                        return
                    }
                    dispatch(HomeAction.updateCurrent(home: home))
                }else {
                    dispatch(AuthAction.updateLogin(login: false))
                }
            }
        }
    }
    
    static func unsubscribe() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            getState()?.authState.listenerCancellable?.cancel()
            dispatch(AuthAction.updateAuthChangeListener(listener: nil))
        }
    }
    
    static func sessionInvalid() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            if TuyaSmartUser.sharedInstance().isLogin {
                dispatch(AuthAction.signOut())
            }
        }
    }
    
    static func fetchUser(uid: String, completion: @escaping () -> Void = {}) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            //            Snapshot.get(.user(userID: uid)) { result in
            //                switch result {
            //                case let .success(user):
            //                    dispatch(AuthAction.updateUser(user: user))
            //                case let .failure(error):
            //                    print(error)
            //                    if getState()?.signUpState.requesting == false {
            //                        dispatch(AuthAction.signOut())
            //                    }
            //                }
            //                completion()
            //            }
        }
    }
    
    static func signOut() -> AppThunkAction {
        AppThunkAction { dispatch, _ in
            TuyaSmartUser.sharedInstance().loginOut({
                dispatch(AuthAction.updateLogin(login: false))
            }, failure: nil)
        }
    }
}
