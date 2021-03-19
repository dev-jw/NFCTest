//
//  SignReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum SignReducer {
    static var reducer: Reducer<SignState> {
        return { action, state in
            var state = state ?? SignState()
            switch action {
            case let action as SignAction:
                switch action {
                case .signUpStarted:
                    state.requesting = true
                    state.error = nil
                    return state
                case .signUpFinished:
                    state.requesting = false
                    state.error = nil
                    return state
                case let .signUpFailed(error):
                    state.requesting = false
                    state.error = error
                    return state
                case .signInStarted:
                    state.requesting = true
                    state.error = nil
                    return state
                case .signInFinished:
                    state.requesting = false
                    state.error = nil
                    return state
                case .signInFailed(error: let error):
                    state.requesting = false
                    state.error = error
                    return state
                }
            default:
                return state
            }
        }
    }
}
