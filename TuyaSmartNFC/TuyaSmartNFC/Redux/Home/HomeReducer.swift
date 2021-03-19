//
//  HomeReducer.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

enum HomeReducer {
    static var reducer: Reducer<HomeState> {
        return { action, state in
            var state = state ?? HomeState()
            guard let action = action as? HomeAction else {
                return state
            }
            switch action {
            case .fetchHomeListStarted:
                state.requesting = true
                state.error = nil
                return state
            case .updateHomes(homes: let homes):
                state.homes = homes
                state.requesting = false
                state.error = nil
                return state
            case .operatorfailed(error: let error):
                state.requesting = false
                state.error = error
                return state
            case .updateCurrent(home: let home):
                state.currentHome = home
                state.requesting = false
                state.error = nil
                return state
            default:
                return state
            }
        }
    }
}
