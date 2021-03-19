//
//  ActivatorReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum ActivatorReducer {
    static var reducer: Reducer<ActivatorState> {
        return { action, state in
            var state = state ?? ActivatorState()
            guard let action = action as? ActivatorAction else {
                return state
            }
            switch action {
            case .matching:
                state.requesting = true
                state.error = nil
                return state
            case .updateToken(token: let token):
                state.requesting = false
                state.token = token
                state.error = nil
                return state
            case .operatorfailed(error: let error):
                state.requesting = false
                state.error = error
                return state
            case .updateResult(result: let res):
                state.res = res
                state.requesting = false
                state.error = nil
                return state
            case .stopConfig:
                state.requesting = false
                state.error = nil
                state.res = ""
                return state
            }
        }
    }
}
