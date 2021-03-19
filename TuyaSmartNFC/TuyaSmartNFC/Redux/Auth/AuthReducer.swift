//
//  AuthReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum AuthReducer {
    static var reducer: Reducer<AuthState> {
        return { action, state in
            var state = state ?? AuthState()
            guard let action = action as? AuthAction else {
                return state
            }
            switch action {
            case .finishInitialLoad:
                state.loadingState = .loaded
                return state
            case let .updateAuthChangeListener(cancellable):
                state.listenerCancellable = cancellable
                return state
            case .updateLogin(login: let login):
                state.isLogin = login
                return state
            }
        }
    }
}
