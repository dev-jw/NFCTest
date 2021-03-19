//
//  AuthState.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Combine
import Foundation
import ReSwift

struct AuthState: StateType {
    enum LoadingState {
        case initial
        case loaded
    }
    
    var loadingState: LoadingState = .initial
    var listenerCancellable: AnyCancellable?
    var isLogin: Bool = false
}
